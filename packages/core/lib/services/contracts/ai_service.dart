import '../../models/ai_event_suggestion.dart';
import '../../utils/result.dart';

/// Contract interface for Gemini AI assistance via Firebase AI Logic / Gemini API.
/// Adheres to Section 8 requirements:
/// - Level 2 structured output (JSON -> Dart model)
/// - Remote Config on/off, model, prompt template
/// - App Check validation
/// - No personal data
/// - Graceful error handling (fail-closed to safe manual input)
abstract interface class IAiEventAssistService {
  Future<Result<AiEventSuggestion>> suggestEventContent({
    required String title,
    String? topic,
    String? currentDescription,
  });
}
