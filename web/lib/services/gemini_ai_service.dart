import 'dart:async';
import 'dart:convert';

import 'package:eventhub_core/eventhub_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'web_contracts.dart';

/// Only controlled, non-personal concepts are sent; never form text or account data.
const aiEventIdeas = <String>[
  'Workshop Flutter và Firebase',
  'Workshop thiết kế UI/UX',
  'Giao lưu âm nhạc',
  'Giải đấu cầu lông',
  'Workshop kỹ năng làm việc nhóm',
];
typedef AiGenerate = Future<String?> Function(String model, String prompt);

class GeminiAiEventAssistService implements IAiEventAssistService {
  GeminiAiEventAssistService({
    required IWebRemoteConfigService remoteConfig,
    required IWebAnalyticsService analytics,
    AiGenerate? generate,
    Future<String?> Function()? appCheckToken,
  }) : _remoteConfig = remoteConfig,
       _analytics = analytics,
       _generate = generate ?? _firebaseGenerate,
       _appCheckToken =
           appCheckToken ?? (() => FirebaseAppCheck.instance.getToken());
  final IWebRemoteConfigService _remoteConfig;
  final IWebAnalyticsService _analytics;
  final AiGenerate _generate;
  final Map<String, List<String>> _recentDrafts = {};
  int _requestNumber = 0;
  final Future<String?> Function() _appCheckToken;

  static Future<String?> _firebaseGenerate(String model, String prompt) async {
    final schema = Schema.object(
      properties: {
        'topic': Schema.string(),
        'description': Schema.string(),
        'audience': Schema.string(),
        'preparation': Schema.string(),
        'activities': Schema.array(items: Schema.string()),
      },
    );
    final generator = FirebaseAI.googleAI().generativeModel(
      model: model,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
        maxOutputTokens: 2048,
        temperature: 0.9,
      ),
    );
    final response = await generator.generateContent([Content.text(prompt)]);
    return response.text;
  }

  Future<Result<AiEventSuggestion>> _failure(
    String code,
    String message,
  ) async {
    try {
      await _analytics.logEvent('ai_error', {
        'feature': 'event_content_suggestion',
        'reason': code,
      });
    } catch (_) {
      /* Telemetry must not block manual entry. */
    }
    return Result.failure(AppFailure(code: code, message: message));
  }

  @override
  Future<Result<AiEventSuggestion>> suggestEventContent({
    required String title,
    String? topic,
    String? currentDescription,
  }) async {
    if (!aiEventIdeas.contains(title) ||
        (topic?.isNotEmpty ?? false) ||
        (currentDescription?.isNotEmpty ?? false)) {
      return await _failure(
        'unsafe_input',
        'Chỉ chọn chủ đề có sẵn để gửi AI; không gửi tên người, email hoặc mô tả riêng.',
      );
    }
    try {
      await _remoteConfig
          .initialize(forceRefresh: true)
          .timeout(const Duration(seconds: 15));
      if (!_remoteConfig.getBool('ai_feature_enabled', defaultValue: false)) {
        return await _failure(
          'ai_disabled',
          'AI đang tắt. Bạn vẫn có thể tự nhập và lưu sự kiện.',
        );
      }
      final model = _remoteConfig
          .getString('ai_model_name', defaultValue: '')
          .trim();
      final template = _remoteConfig
          .getString('ai_prompt_template', defaultValue: '')
          .trim();
      if (model.isEmpty || template.isEmpty) {
        return await _failure(
          'ai_not_configured',
          'Chưa cấu hình model/prompt AI. Bạn có thể tự nhập sự kiện.',
        );
      }
      final token = await _appCheckToken().timeout(const Duration(seconds: 10));
      if (token == null || token.isEmpty) {
        return await _failure(
          'app_check_required',
          'Chưa xác minh được ứng dụng. Bạn có thể tự nhập sự kiện.',
        );
      }
      await _analytics.logEvent('ai_request', {
        'feature': 'event_content_suggestion',
        'model': model,
      });
      final recent = _recentDrafts[title] ?? <String>[];
      final variation = ++_requestNumber;
      final text = await _generate(
        model,
        '$template\nChủ đề đã chọn: $title\nLần đề xuất: $variation. Bám sát kiến thức và hoạt động đặc trưng của chủ đề. Đổi góc tiếp cận, mục tiêu thực hành và trình tự hoạt động, không chỉ đổi từ đồng nghĩa. Không lặp các bản nháp trước: ${jsonEncode(recent)}\nChỉ đề xuất nội dung chung; không tạo tên người, email, số điện thoại hoặc địa chỉ cá nhân.',
      ).timeout(const Duration(seconds: 30));
      final suggestion = AiEventSuggestion.fromRawText(text ?? '');
      final draft = jsonEncode({
        'description': suggestion.description,
        'activities': suggestion.activities,
      });
      if (recent.contains(draft)) {
        return await _failure(
          'duplicate_response',
          'AI trả lại bản nháp cũ. Form được giữ nguyên; hãy tạo lại.',
        );
      }
      _recentDrafts[title] = [
        ...recent,
        draft,
      ].reversed.take(3).toList().reversed.toList();
      return Result.success(suggestion);
    } on QuotaExceeded {
      return await _failure(
        'quota_exhausted',
        'AI đã hết hạn mức tạm thời. Bạn vẫn có thể tự nhập sự kiện.',
      );
    } on FormatException {
      return await _failure(
        'invalid_response',
        'AI trả về nội dung không hợp lệ. Form của bạn được giữ nguyên; hãy thử lại hoặc nhập tay.',
      );
    } on TimeoutException {
      return await _failure(
        'timeout',
        'AI phản hồi quá lâu. Hãy thử lại hoặc tiếp tục nhập tay.',
      );
    } catch (_) {
      // Do not log exception strings: SDK errors may contain request details.
      return await _failure(
        'ai_unavailable',
        'Không dùng được AI lúc này (kết nối, hạn mức hoặc cấu hình). Bạn vẫn có thể nhập tay.',
      );
    }
  }
}
