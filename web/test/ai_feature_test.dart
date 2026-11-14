import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/services/gemini_ai_service.dart';
import 'package:eventhub_web/services/web_contracts.dart';
import 'package:eventhub_web/viewmodels/ai_event_assist_viewmodel.dart';

class Config implements IWebRemoteConfigService {
  bool enabled = true;
  bool refreshFails = false;
  bool forceRequested = false;
  @override
  Future<void> initialize({bool forceRefresh = false}) async {
    forceRequested = forceRefresh;
    if (refreshFails) throw StateError('offline');
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) => enabled;
  @override
  int getInt(String key, {int defaultValue = 0}) => defaultValue;
  @override
  String getString(String key, {String defaultValue = ''}) =>
      key == 'ai_model_name' ? 'configured-model' : 'configured-prompt';
}

class Analytics implements IWebAnalyticsService {
  bool fail = false;
  final events = <String>[];
  final params = <Map<String, Object>?>[];
  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add(name);
    params.add(parameters);
    if (fail) throw StateError('analytics unavailable');
  }

  @override
  Future<void> setUserId(String? uid) async {}
}

const testIdea = 'Workshop chụp ảnh bằng điện thoại cho người mới';
final payload = {
  'topic': 'Công nghệ',
  'description': 'Thực hành theo nhóm.',
  'audience': 'Sinh viên',
  'preparation': 'Laptop',
  'activities': ['Giới thiệu', 'Thực hành'],
};
void main() {
  late Config config;
  late Analytics analytics;
  late int calls;
  GeminiAiEventAssistService service({
    AiGenerate? generate,
    Future<String?> Function()? token,
  }) => GeminiAiEventAssistService(
    remoteConfig: config,
    analytics: analytics,
    appCheckToken: token ?? (() async => 'test-token'),
    generate:
        generate ??
        ((model, prompt) async {
          calls++;
          expect(model, 'configured-model');
          expect(prompt, contains('configured-prompt'));
          return jsonEncode(payload);
        }),
  );
  setUp(() {
    config = Config();
    analytics = Analytics();
    calls = 0;
  });
  test('schema validates required fields and rejects malformed/plain text/contact output', () {
    expect(
      AiEventSuggestion.fromRawText(jsonEncode(payload)).activities,
      hasLength(2),
    );
    for (final value in [
      'plain text',
      '{}',
      jsonEncode({...payload, 'startsAt': '2030-01-01T10:00:00'}),
      jsonEncode({
        ...payload,
        'activities': [1],
      }),
      jsonEncode({...payload, 'description': 'Contact test@example.org'}),
    ]) {
      expect(() => AiEventSuggestion.fromRawText(value), throwsFormatException);
    }
  });
  test('configured model/prompt and App Check precede generation', () async {
    final result = await service().suggestEventContent(title: testIdea);
    expect(result.isSuccess, isTrue);
    expect(calls, 1);
    expect(config.forceRequested, isTrue);
    expect(analytics.events, ['ai_request']);
  });
  test(
    'regeneration sends previous draft and rejects identical content',
    () async {
      final prompts = <String>[];
      final instance = service(
        generate: (model, prompt) async {
          prompts.add(prompt);
          return jsonEncode(payload);
        },
      );
      expect(
        (await instance.suggestEventContent(title: testIdea)).isSuccess,
        isTrue,
      );
      final repeated = await instance.suggestEventContent(title: testIdea);
      expect(repeated.failureOrNull?.code, 'duplicate_response');
      expect(prompts.last, contains(payload['description']));
      expect(prompts.first, isNot(prompts.last));
    },
  );
  test(
    'rejects contact details and full form fields before any network call',
    () async {
      for (final input in [
        'test@example.org',
        '+84912345678',
        'https://example.org/profile',
        '',
        'a' * 501,
      ]) {
        expect(
          (await service().suggestEventContent(title: input)).isFailure,
          isTrue,
        );
      }
      expect(
        (await service().suggestEventContent(
          title: testIdea,
          currentDescription: 'private',
        )).isFailure,
        isTrue,
      );
      expect(calls, 0);
      expect(analytics.events, everyElement('ai_error'));
    },
  );
  test(
    'RC disabled makes no request and leaves manual entry available',
    () async {
      config.enabled = false;
      expect(
        (await service().suggestEventContent(title: testIdea))
            .failureOrNull
            ?.code,
        'ai_disabled',
      );
      expect(calls, 0);
    },
  );
  test('accepts a custom idea and limits generation to content fields without logging the idea', () async {
    String? sent;
    final result = await service(
      generate: (_, prompt) async {
        sent = prompt;
        return jsonEncode(payload);
      },
    ).suggestEventContent(title: testIdea);
    expect(result.isSuccess, isTrue);
    expect(sent, contains(testIdea));
    expect(sent, contains('KHÔNG đề xuất ngày'));
    expect(sent, contains('đúng 5 khóa'));
    expect(analytics.params.toString(), isNot(contains(testIdea)));
  });
  test(
    'suspected names are rejected before config, token or model calls',
    () async {
      var tokens = 0;
      final instance = service(
        token: () async {
          tokens++;
          return 'token';
        },
      );
      for (final idea in [
        'Workshop với Nguyễn Minh Anh',
        'Workshop của John Smith',
        'giao lưu với nguyễn minh anh',
        'Diễn giả: alex',
      ]) {
        expect(
          (await instance.suggestEventContent(title: idea)).failureOrNull?.code,
          'unsafe_input',
        );
      }
      expect(config.forceRequested, isFalse);
      expect(tokens, 0);
      expect(calls, 0);
      expect(analytics.params.toString(), isNot(contains('Minh Anh')));
    },
  );
  test('analytics outage does not prevent generation or acceptance', () async {
    analytics.fail = true;
    final instance = service();
    expect(
      (await instance.suggestEventContent(title: testIdea)).isSuccess,
      isTrue,
    );
    expect(calls, 1);
    final c = ProviderContainer(
      overrides: [
        geminiAiServiceProvider.overrideWithValue(service()),
        webAnalyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(aiEventAssistViewModelProvider, (_, __) {});
    addTearDown(sub.close);
    final vm = c.read(aiEventAssistViewModelProvider.notifier);
    await vm.requestSuggestion(title: testIdea);
    vm.markAccepted();
    await Future<void>.delayed(Duration.zero);
    expect(c.read(aiEventAssistViewModelProvider).isAccepted, isTrue);
  });
  test('RC refresh failure blocks generation with stale config', () async {
    config.refreshFails = true;
    expect(
      (await service().suggestEventContent(title: testIdea)).isFailure,
      isTrue,
    );
    expect(calls, 0);
  });
  test('missing or failed App Check stops generation', () async {
    for (final token in <Future<String?> Function()>[
      () async => null,
      () async => throw StateError('invalid'),
    ]) {
      expect(
        (await service(token: token).suggestEventContent(title: testIdea))
            .isFailure,
        isTrue,
      );
    }
    expect(calls, 0);
    expect(analytics.events, isNot(contains('ai_request')));
  });
  test('network/quota errors cannot masquerade as generated content or leak details', () async {
    final result = await service(
      generate: (_, _) async => throw StateError('429 secret@example.org'),
    ).suggestEventContent(title: testIdea);
    expect(result.isFailure, isTrue);
    expect(analytics.events, ['ai_request', 'ai_error']);
    expect(analytics.params.toString(), isNot(contains('secret@example.org')));
  });
  test('quota error is reported without generated fallback', () async {
    final result = await service(
      generate: (_, _) async => throw QuotaExceeded('quota'),
    ).suggestEventContent(title: testIdea);
    expect(result.failureOrNull?.code, 'quota_exhausted');
  });
  test('invalid response fails without offline generation', () async {
    final result = await service(generate: (_, _) async => '{}')
        .suggestEventContent(title: testIdea);
    expect(result.failureOrNull?.code, 'invalid_response');
  });
  test('accept only an existing result, once per request; failure clears stale suggestion', () async {
    final c = ProviderContainer(
      overrides: [
        geminiAiServiceProvider.overrideWithValue(service()),
        webAnalyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    final sub = c.listen(aiEventAssistViewModelProvider, (_, _) {});
    addTearDown(() {
      sub.close();
      c.dispose();
    });
    final vm = c.read(aiEventAssistViewModelProvider.notifier);
    vm.markAccepted();
    expect(analytics.events, isEmpty);
    await vm.requestSuggestion(title: testIdea);
    vm.markAccepted();
    vm.markAccepted();
    expect(
      analytics.events.where((e) => e == 'ai_result_accepted'),
      hasLength(1),
    );
    config.enabled = false;
    await vm.requestSuggestion(title: testIdea);
    expect(c.read(aiEventAssistViewModelProvider).suggestion, isNull);
    vm.markAccepted();
    expect(
      analytics.events.where((e) => e == 'ai_result_accepted'),
      hasLength(1),
    );
  });
  test(
    'disposing a form while request runs does not update another session',
    () async {
      final delayed = Completer<String?>();
      final c = ProviderContainer(
        overrides: [
          geminiAiServiceProvider.overrideWithValue(
            service(generate: (_, _) => delayed.future),
          ),
        ],
      );
      final sub = c.listen(aiEventAssistViewModelProvider, (_, _) {});
      final task = c
          .read(aiEventAssistViewModelProvider.notifier)
          .requestSuggestion(title: testIdea);
      await Future<void>.delayed(Duration.zero);
      sub.close();
      c.dispose();
      delayed.complete(jsonEncode(payload));
      expect(await task, isNull);
    },
  );
}
