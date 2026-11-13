import 'dart:async';
import 'dart:convert';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:http/http.dart' as http;
import 'web_contracts.dart';
import 'web_firebase_bootstrap.dart';

class GeminiAiEventAssistService implements IAiEventAssistService {
  GeminiAiEventAssistService({
    required IWebRemoteConfigService remoteConfig,
    required IWebAnalyticsService analytics,
    http.Client? httpClient,
    FirebaseAppCheck? appCheck,
    String? apiKey,
  })  : _remoteConfig = remoteConfig,
        _analytics = analytics,
        _httpClient = httpClient ?? http.Client(),
        _appCheck = appCheck,
        _apiKey = apiKey;

  final IWebRemoteConfigService _remoteConfig;
  final IWebAnalyticsService _analytics;
  final http.Client _httpClient;
  final FirebaseAppCheck? _appCheck;
  final String? _apiKey;

  String get _effectiveApiKey {
    final key = _apiKey;
    if (key != null && key.isNotEmpty) return key;
    return WebFirebaseEnvironment.apiKey;
  }

  @override
  Future<Result<AiEventSuggestion>> suggestEventContent({
    required String title,
    String? topic,
    String? currentDescription,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.length < 3) {
      return Result.failure(
        const AppFailure(
          code: 'invalid_input',
          message:
              'Vui lòng nhập tiêu đề hoặc ý tưởng sự kiện (tối thiểu 3 ký tự) trước khi gọi AI.',
        ),
      );
    }

    // 1. Remote Config kill-switch
    final isEnabled = _remoteConfig.getBool('ai_feature_enabled', defaultValue: true);
    if (!isEnabled) {
      unawaited(
        _analytics.logEvent('ai_error', {
          'feature': 'event_content_suggestion',
          'reason': 'disabled_by_remote_config',
        }),
      );
      return Result.failure(
        const AppFailure(
          code: 'ai_disabled',
          message:
              'Tính năng AI đang tạm tắt từ hệ thống (Remote Config). Bạn có thể tự nhập thông tin sự kiện bên dưới.',
        ),
      );
    }

    final modelName = _remoteConfig.getString(
      'ai_model_name',
      defaultValue: 'gemini-1.5-flash',
    );
    final promptTemplate = _remoteConfig.getString(
      'ai_prompt_template',
      defaultValue:
          'Bạn là trợ lý AI cho ứng dụng EventHub của trường đại học. Dựa trên ý chính hoặc tiêu đề do CLB cung cấp, hãy đề xuất nội dung sự kiện theo định dạng JSON có cấu trúc gồm các trường: topic, description, audience, preparation, activities. Tuyệt đối không gửi hoặc yêu cầu thông tin cá nhân.',
    );

    // 2. Log ai_request analytics
    unawaited(
      _analytics.logEvent('ai_request', {
        'feature': 'event_content_suggestion',
        'model': modelName,
        'title_length': cleanTitle.length,
      }),
    );

    // 3. Fallback deterministic generator if API key is not configured
    final apiKey = _effectiveApiKey;
    if (apiKey.isEmpty) {
      return _generateOfflineSuggestion(cleanTitle, topic);
    }

    // 4. Gemini Developer API call with App Check token
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      try {
        final appCheckInstance = _appCheck ?? FirebaseAppCheck.instance;
        final token = await appCheckInstance.getToken().timeout(
          const Duration(seconds: 3),
        );
        if (token != null && token.isNotEmpty) {
          headers['X-Firebase-AppCheck'] = token;
        }
      } catch (_) {
        // App Check is optional in debug/unsupported web environments
      }

      final promptPayload = '''
$promptTemplate

Thông tin sự kiện do CLB cung cấp:
- Tiêu đề / Ý tưởng: $cleanTitle
${topic != null && topic.trim().isNotEmpty ? '- Chủ đề dự kiến: ${topic.trim()}' : ''}
${currentDescription != null && currentDescription.trim().isNotEmpty ? '- Ý tưởng bổ sung: ${currentDescription.trim()}' : ''}

QUY TẮC BẮT BUỘC:
1. Xuất ra định dạng JSON thuần túy (không markdown bao quanh).
2. Không chứa bất kỳ thông tin cá nhân nào (tên người, email, số điện thoại, ảnh).
3. Đầy đủ 5 trường:
{
  "topic": "Chủ đề ngắn gọn (<= 40 ký tự)",
  "description": "Mô tả hấp dẫn về mục đích và giá trị sự kiện (2-4 câu)",
  "audience": "Đối tượng sinh viên phù hợp tham gia",
  "preparation": "Yêu cầu chuẩn bị khi đến tham gia",
  "activities": [
    "Tên hoạt động 1",
    "Tên hoạt động 2",
    "Tên hoạt động 3"
  ]
}
''';

      final requestBody = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': promptPayload}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        }
      });

      final response = await _httpClient
          .post(url, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final candidates = responseData['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final rawText = parts[0]['text'] as String? ?? '';
            final suggestion = AiEventSuggestion.fromRawText(rawText);
            return Result.success(suggestion);
          }
        }
        return Result.failure(
          const AppFailure(
            code: 'ai_empty_response',
            message: 'Gemini phản hồi nhưng không có nội dung phù hợp. Bạn có thể tự nhập thông tin.',
          ),
        );
      } else if (response.statusCode == 429) {
        unawaited(
          _analytics.logEvent('ai_error', {
            'feature': 'event_content_suggestion',
            'status_code': 429,
            'reason': 'quota_exhausted',
          }),
        );
        return Result.failure(
          const AppFailure(
            code: 'quota_exhausted',
            message:
                'Gemini AI đang vượt hạn mức truy vấn tạm thời (Quota 429). Bạn có thể tiếp tục tự nhập sự kiện bên dưới.',
          ),
        );
      } else {
        unawaited(
          _analytics.logEvent('ai_error', {
            'feature': 'event_content_suggestion',
            'status_code': response.statusCode,
          }),
        );
        return _generateOfflineSuggestion(cleanTitle, topic,
            warning:
                'Không thể kết nối Gemini API (${response.statusCode}). Đã áp dụng mẫu đề xuất thông minh dự phòng.');
      }
    } catch (e) {
      unawaited(
        _analytics.logEvent('ai_error', {
          'feature': 'event_content_suggestion',
          'error': e.toString(),
        }),
      );
      return _generateOfflineSuggestion(cleanTitle, topic,
          warning:
              'Lỗi đường truyền mạng khi gọi AI. Đã chuyển sang chế độ đề xuất thông minh ngoại tuyến.');
    }
  }

  /// High-quality rule-based fallback suggestion ensuring the flow never breaks even when offline.
  Result<AiEventSuggestion> _generateOfflineSuggestion(
    String title,
    String? topic, {
    String? warning,
  }) {
    final lower = title.toLowerCase();
    String detectedTopic = topic?.trim() ?? '';
    String description = '';
    String audience = '';
    String preparation = '';
    List<String> activities = [];

    if (lower.contains('workshop') ||
        lower.contains('lập trình') ||
        lower.contains('flutter') ||
        lower.contains('code') ||
        lower.contains('tech') ||
        lower.contains('ai')) {
      detectedTopic = detectedTopic.isEmpty ? 'Công nghệ & Kỹ thuật' : detectedTopic;
      description =
          'Buổi chia sẻ kiến thức chuyên sâu và thực hành lập trình xoay quanh chủ đề "$title". Sinh viên sẽ được tiếp cận các kiến thức mới nhất và thực hành trực tiếp cùng diễn giả.';
      audience = 'Sinh viên ngành Công nghệ thông tin, Kỹ thuật phần mềm và những ai quan tâm đến công nghệ.';
      preparation = 'Mang theo laptop cá nhân đã cài đặt sẵn môi trường phát triển và tài khoản Google.';
      activities = [
        'Check-in, ổn định chỗ ngồi và nhận tài liệu workshop',
        'Diễn giả chia sẻ tổng quan kiến trúc và kinh nghiệm thực chiến',
        'Thực hành trực tiếp (Hands-on Lab) và giải đáp thắc mắc (Q&A)'
      ];
    } else if (lower.contains('âm nhạc') ||
        lower.contains('acoustic') ||
        lower.contains('nhạc') ||
        lower.contains('văn nghệ') ||
        lower.contains('ca nhạc')) {
      detectedTopic = detectedTopic.isEmpty ? 'Văn hóa & Nghệ thuật' : detectedTopic;
      description =
          'Đêm nhạc acoustic thư giãn "$title" với sự góp mặt của các ban nhạc sinh viên tài năng. Hãy cùng hòa mình vào không gian âm nhạc ấm cúng và kết nối bạn bè.';
      audience = 'Toàn thể sinh viên và người yêu âm nhạc trong toàn trường.';
      preparation = 'Trang phục thoải mái, mang theo tinh thần nhiệt huyết và check-in đúng giờ.';
      activities = [
        'Đón tiếp khán giả và check-in vào khán phòng',
        'Các tiết mục biểu diễn âm nhạc đặc sắc',
        'Giao lưu ca hát mở (Open mic) và chụp ảnh lưu niệm'
      ];
    } else if (lower.contains('thể thao') ||
        lower.contains('bóng') ||
        lower.contains('cầu lông') ||
        lower.contains('giải đấu') ||
        lower.contains('chạy')) {
      detectedTopic = detectedTopic.isEmpty ? 'Thể thao & Sức khỏe' : detectedTopic;
      description =
          'Hoạt động thể thao rèn luyện sức khỏe "$title". Cơ hội giao lưu, nâng cao tinh thần đồng đội và thỏa mãn niềm đam mê thể thao của các bạn trẻ.';
      audience = 'Các bạn sinh viên yêu thích thể thao và mong muốn rèn luyện thể chất.';
      preparation = 'Trang phục thể thao chuyên dụng, giày thể thao và nước uống cá nhân.';
      activities = [
        'Khởi động chung và phổ biến thể lệ thi đấu',
        'Các trận đấu giao lưu sôi nổi',
        'Tổng kết, trao thưởng lưu niệm và chụp ảnh tập thể'
      ];
    } else {
      detectedTopic = detectedTopic.isEmpty ? 'Kỹ năng & Hoạt động sinh viên' : detectedTopic;
      description =
          'Sự kiện "$title" do Câu lạc bộ tổ chức nhằm tạo sân chơi bổ ích, giao lưu học hỏi và phát triển kỹ năng cho cộng đồng sinh viên.';
      audience = 'Tất cả sinh viên quan tâm và muốn mở rộng kết nối bạn bè.';
      preparation = 'Mang theo sổ tay ghi chép, thẻ sinh viên để check-in và tinh thần học hỏi tích cực.';
      activities = [
        'Đón tiếp người tham gia và phát tài liệu giới thiệu',
        'Nội dung chính của sự kiện và thảo luận nhóm',
        'Tổng kết chương trình và chụp ảnh kỷ niệm'
      ];
    }

    return Result.success(
      AiEventSuggestion(
        topic: detectedTopic,
        description: description,
        audience: audience,
        preparation: preparation,
        activities: activities,
      ),
    );
  }
}
