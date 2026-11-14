import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../app/providers.dart';

class AiEventAssistState {
  const AiEventAssistState({
    this.isLoading = false,
    this.suggestion,
    this.errorMessage,
    this.isAccepted = false,
    this.isAiGenerated = false,
  });

  final bool isLoading;
  final AiEventSuggestion? suggestion;
  final String? errorMessage;
  final bool isAccepted;
  final bool isAiGenerated;

  AiEventAssistState copyWith({
    bool? isLoading,
    AiEventSuggestion? suggestion,
    String? errorMessage,
    bool? isAccepted,
    bool? isAiGenerated,
  }) => AiEventAssistState(
    isLoading: isLoading ?? this.isLoading,
    suggestion: suggestion ?? this.suggestion,
    errorMessage: errorMessage,
    isAccepted: isAccepted ?? this.isAccepted,
    isAiGenerated: isAiGenerated ?? this.isAiGenerated,
  );
}

final aiEventAssistViewModelProvider =
    NotifierProvider.autoDispose<AiEventAssistViewModel, AiEventAssistState>(
      AiEventAssistViewModel.new,
    );

class AiEventAssistViewModel extends Notifier<AiEventAssistState> {
  @override
  AiEventAssistState build() => const AiEventAssistState();

  Future<AiEventSuggestion?> requestSuggestion({
    required String title,
    String? topic,
    String? currentDescription,
  }) async {
    if (state.isLoading) return null;
    state = const AiEventAssistState(isLoading: true);

    final service = ref.read(geminiAiServiceProvider);
    final result = await service.suggestEventContent(
      title: title,
      topic: topic,
      currentDescription: currentDescription,
    );

    if (!ref.mounted) return null;
    return result.when(
      success: (suggestion) {
        state = state.copyWith(
          isLoading: false,
          suggestion: suggestion,
          isAiGenerated: true,
          errorMessage: null,
        );
        return suggestion;
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return null;
      },
    );
  }

  void markAccepted() {
    if (state.suggestion == null || state.isAccepted || state.isLoading) return;
    state = state.copyWith(isAccepted: true);
    final analytics = ref.read(webAnalyticsServiceProvider);
    unawaited(
      analytics
          .logEvent('ai_result_accepted', {
            'feature': 'event_content_suggestion',
          })
          .catchError((Object _) {}),
    );
  }

  void clearMessage() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const AiEventAssistState();
  }
}
