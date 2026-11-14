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
  final events = <String>[];
  final params = <Map<String, Object>?>[];
  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add(name);
    params.add(parameters);
  }

  @override
  Future<void> setUserId(String? uid) async {}
}

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
    final result = await service().suggestEventContent(
      title: aiEventIdeas.first,
    );
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
        (await instance.suggestEventContent(title: aiEventIdeas.first))
            .isSuccess,
        isTrue,
      );
      final repeated = await instance.suggestEventContent(
        title: aiEventIdeas.first,
      );
      expect(repeated.failureOrNull?.code, 'duplicate_response');
      expect(prompts.last, contains(payload['description']));
      expect(prompts.first, isNot(prompts.last));
    },
  );
  test('never sends free text names, email or form description', () async {
    for (final input in ['Nguyễn Văn A', 'test@example.org', '+84912345678']) {
      expect(
        (await service().suggestEventContent(title: input)).isFailure,
        isTrue,
      );
    }
    expect(
      (await service().suggestEventContent(
        title: aiEventIdeas.first,
        currentDescription: 'private',
      )).isFailure,
      isTrue,
    );
    expect(calls, 0);
    expect(analytics.events, everyElement('ai_error'));
  });
  test(
    'RC disabled makes no request and leaves manual entry available',
    () async {
      config.enabled = false;
      expect(
        (await service().suggestEventContent(title: aiEventIdeas.first))
            .failureOrNull
            ?.code,
        'ai_disabled',
      );
      expect(calls, 0);
    },
  );
  test('RC refresh failure blocks generation with stale config', () async {
    config.refreshFails = true;
    expect(
      (await service().suggestEventContent(title: aiEventIdeas.first))
          .isFailure,
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
        (await service(token: token)
                .suggestEventContent(title: aiEventIdeas.first))
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
    ).suggestEventContent(title: aiEventIdeas.first);
    expect(result.isFailure, isTrue);
    expect(analytics.events, ['ai_request', 'ai_error']);
    expect(analytics.params.toString(), isNot(contains('secret@example.org')));
  });
  test('quota error is reported without generated fallback', () async {
    final result = await service(
      generate: (_, _) async => throw QuotaExceeded('quota'),
    ).suggestEventContent(title: aiEventIdeas.first);
    expect(result.failureOrNull?.code, 'quota_exhausted');
  });
  test('invalid response fails without offline generation', () async {
    final result = await service(generate: (_, _) async => '{}')
        .suggestEventContent(title: aiEventIdeas.first);
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
    await vm.requestSuggestion(title: aiEventIdeas.first);
    vm.markAccepted();
    vm.markAccepted();
    expect(
      analytics.events.where((e) => e == 'ai_result_accepted'),
      hasLength(1),
    );
    config.enabled = false;
    await vm.requestSuggestion(title: aiEventIdeas.first);
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
          .requestSuggestion(title: aiEventIdeas.first);
      await Future<void>.delayed(Duration.zero);
      sub.close();
      c.dispose();
      delayed.complete(jsonEncode(payload));
      expect(await task, isNull);
    },
  );
}
