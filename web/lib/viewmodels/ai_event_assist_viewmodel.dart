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
  }) =>
      AiEventAssistState(
        isLoading: isLoading ?? this.isLoading,
        suggestion: suggestion ?? this.suggestion,
        errorMessage: errorMessage,
        isAccepted: isAccepted ?? this.isAccepted,
        isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      );
}

final aiEventAssistViewModelProvider =
    NotifierProvider<AiEventAssistViewModel, AiEventAssistState>(
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    final service = ref.read(geminiAiServiceProvider);
    final result = await service.suggestEventContent(
      title: title,
      topic: topic,
      currentDescription: currentDescription,
    );

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
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
    );
  }

  void markAccepted() {
    state = state.copyWith(isAccepted: true);
    final analytics = ref.read(webAnalyticsServiceProvider);
    unawaited(
      analytics.logEvent('ai_result_accepted', {
        'feature': 'event_content_suggestion',
        'accepted_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  void clearMessage() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const AiEventAssistState();
  }
}
