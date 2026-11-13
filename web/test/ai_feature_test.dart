import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/services/gemini_ai_service.dart';
import 'package:eventhub_web/services/web_contracts.dart';
import 'package:eventhub_web/viewmodels/ai_event_assist_viewmodel.dart';

class _FakeRemoteConfig implements IWebRemoteConfigService {
  _FakeRemoteConfig({
    this.enabled = true,
  });

  bool enabled;
  String modelName = 'gemini-1.5-flash';

  @override
  Future<void> initialize() async {}

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    if (key == 'ai_feature_enabled') return enabled;
    return defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) => defaultValue;

  @override
  String getString(String key, {String defaultValue = ''}) {
    if (key == 'ai_model_name') return modelName;
    return defaultValue;
  }
}

class _FakeAnalytics implements IWebAnalyticsService {
  final List<String> loggedEvents = [];
  final List<Map<String, Object>?> loggedParams = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    loggedEvents.add(name);
    loggedParams.add(parameters);
  }

  @override
  Future<void> setUserId(String? uid) async {}
}

void main() {
  group('AiEventSuggestion model (Level 2 Structured Output)', () {
    test('parses clean JSON into structured model', () {
      const jsonStr = '''
      {
        "topic": "Lập trình Di động",
        "description": "Workshop chuyên sâu về Flutter.",
        "audience": "Sinh viên ngành CNTT",
        "preparation": "Mang theo laptop cài sẵn Flutter",
        "activities": ["Đón tiếp", "Thực hành", "Q&A"]
      }
      ''';

      final suggestion =
          AiEventSuggestion.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(suggestion.topic, 'Lập trình Di động');
      expect(suggestion.description, 'Workshop chuyên sâu về Flutter.');
      expect(suggestion.audience, 'Sinh viên ngành CNTT');
      expect(suggestion.preparation, 'Mang theo laptop cài sẵn Flutter');
      expect(suggestion.activities, ['Đón tiếp', 'Thực hành', 'Q&A']);
    });

    test('parses markdown-fenced json string gracefully', () {
      const raw = '''
      ```json
      {
        "topic": "Thiết kế UI/UX",
        "description": "Hướng dẫn sử dụng Figma căn bản.",
        "audience": "Tất cả sinh viên quan tâm",
        "preparation": "Tạo tài khoản Figma",
        "activities": ["Giới thiệu", "Demo"]
      }
      ```
      ''';

      final suggestion = AiEventSuggestion.fromRawText(raw);
      expect(suggestion.topic, 'Thiết kế UI/UX');
      expect(suggestion.description, 'Hướng dẫn sử dụng Figma căn bản.');
      expect(suggestion.activities.length, 2);
    });
  });

  group('GeminiAiEventAssistService', () {
    test('valid input calls Gemini API and returns structured suggestion', () async {
      final remoteConfig = _FakeRemoteConfig();
      final analytics = _FakeAnalytics();

      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('gemini-1.5-flash'));
        expect(request.headers['Content-Type'], 'application/json');

        // Check privacy requirement: NO personal data (names, emails) in payload
        final bodyText = request.body;
        expect(bodyText, isNot(contains('@gmail.com')));
        expect(bodyText, isNot(contains('@fpt.edu.vn')));

        final responseJson = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'topic': 'Trí tuệ Nhân tạo',
                      'description': 'Hội thảo AI trong đời sống sinh viên.',
                      'audience': 'Sinh viên yêu thích AI',
                      'preparation': 'Sổ tay ghi chú',
                      'activities': ['Khai mạc', 'Thảo luận', 'Bế mạc']
                    })
                  }
                ]
              }
            }
          ]
        };

        return http.Response(jsonEncode(responseJson), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = GeminiAiEventAssistService(
        remoteConfig: remoteConfig,
        analytics: analytics,
        httpClient: mockClient,
        apiKey: 'test-api-key',
      );

      final result = await service.suggestEventContent(
        title: 'Hội thảo Trí tuệ Nhân tạo 2026',
        topic: 'Công nghệ',
      );

      expect(result.isSuccess, isTrue);
      final suggestion = result.dataOrNull!;
      expect(suggestion.topic, 'Trí tuệ Nhân tạo');
      expect(suggestion.description, 'Hội thảo AI trong đời sống sinh viên.');
      expect(suggestion.activities.length, 3);

      expect(analytics.loggedEvents, contains('ai_request'));
    });

    test('respects Remote Config on/off kill-switch and logs ai_error', () async {
      final remoteConfig = _FakeRemoteConfig(enabled: false);
      final analytics = _FakeAnalytics();

      final service = GeminiAiEventAssistService(
        remoteConfig: remoteConfig,
        analytics: analytics,
        apiKey: 'test-api-key',
      );

      final result = await service.suggestEventContent(
        title: 'Workshop lập trình di động',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'ai_disabled');
      expect(
        result.failureOrNull?.message,
        contains('tạm tắt từ hệ thống (Remote Config)'),
      );
      expect(analytics.loggedEvents, contains('ai_error'));
    });

    test('handles HTTP 429 Quota Exceeded gracefully without crashing', () async {
      final remoteConfig = _FakeRemoteConfig();
      final analytics = _FakeAnalytics();

      final mockClient = MockClient((request) async {
        return http.Response('Resource Exhausted (Quota)', 429);
      });

      final service = GeminiAiEventAssistService(
        remoteConfig: remoteConfig,
        analytics: analytics,
        httpClient: mockClient,
        apiKey: 'test-api-key',
      );

      final result = await service.suggestEventContent(
        title: 'Giao lưu câu lạc bộ âm nhạc',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'quota_exhausted');
      expect(analytics.loggedEvents, contains('ai_error'));
    });

    test('rejects inputs shorter than 3 characters before network call', () async {
      final remoteConfig = _FakeRemoteConfig();
      final analytics = _FakeAnalytics();

      final service = GeminiAiEventAssistService(
        remoteConfig: remoteConfig,
        analytics: analytics,
        apiKey: 'test-api-key',
      );

      final result = await service.suggestEventContent(title: '  a ');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'invalid_input');
      expect(analytics.loggedEvents, isEmpty);
    });
  });

  group('AiEventAssistViewModel', () {
    test('requests suggestion, updates state, and marks accepted', () async {
      final remoteConfig = _FakeRemoteConfig();
      final analytics = _FakeAnalytics();

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'topic': 'Âm nhạc',
                        'description': 'Đêm nhạc acoustic.',
                        'audience': 'Sinh viên',
                        'preparation': 'Nước uống',
                        'activities': ['Văn nghệ', 'Giao lưu']
                      })
                    }
                  ]
                }
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = GeminiAiEventAssistService(
        remoteConfig: remoteConfig,
        analytics: analytics,
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final container = ProviderContainer(
        overrides: [
          webRemoteConfigServiceProvider.overrideWithValue(remoteConfig),
          webAnalyticsServiceProvider.overrideWithValue(analytics),
          geminiAiServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(aiEventAssistViewModelProvider.notifier);
      final res = await vm.requestSuggestion(title: 'Acoustic Night');

      expect(res, isNotNull);
      expect(res?.topic, 'Âm nhạc');
      expect(
        container.read(aiEventAssistViewModelProvider).isAiGenerated,
        isTrue,
      );

      vm.markAccepted();
      expect(container.read(aiEventAssistViewModelProvider).isAccepted, isTrue);
      expect(analytics.loggedEvents, contains('ai_result_accepted'));

      vm.clearMessage();
      vm.reset();
      expect(
        container.read(aiEventAssistViewModelProvider).isAiGenerated,
        isFalse,
      );
    });
  });
}
