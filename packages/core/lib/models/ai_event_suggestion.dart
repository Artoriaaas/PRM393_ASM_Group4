import 'dart:convert';

/// Level 2 Structured AI suggestion model for event content drafting.
/// Strictly contains event-related planning fields; never stores or accepts personal data.
class AiEventSuggestion {
  const AiEventSuggestion({
    required this.topic,
    required this.description,
    required this.audience,
    required this.preparation,
    required this.activities,
  });

  final String topic;
  final String description;
  final String audience;
  final String preparation;
  final List<String> activities;

  factory AiEventSuggestion.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'];
    final activitiesList = <String>[];
    if (rawActivities is List) {
      for (final item in rawActivities) {
        if (item != null && item.toString().trim().isNotEmpty) {
          activitiesList.add(item.toString().trim());
        }
      }
    } else if (rawActivities is String && rawActivities.isNotEmpty) {
      activitiesList.addAll(
        rawActivities
            .split('\n')
            .map((e) => e.replaceAll(RegExp(r'^[-*•\d.]+\s*'), '').trim())
            .where((e) => e.isNotEmpty),
      );
    }

    return AiEventSuggestion(
      topic: (json['topic'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      audience: (json['audience'] as String? ?? '').trim(),
      preparation: (json['preparation'] as String? ?? '').trim(),
      activities: List.unmodifiable(activitiesList),
    );
  }

  /// Parses JSON from raw LLM text response, handling possible markdown code block fences.
  factory AiEventSuggestion.fromRawText(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return AiEventSuggestion.fromJson(decoded);
      } else if (decoded is Map) {
        return AiEventSuggestion.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Fallback parsing if JSON is slightly malformed
      final topicMatch = RegExp(r'"topic"\s*:\s*"([^"]+)"').firstMatch(cleaned);
      final descMatch =
          RegExp(r'"description"\s*:\s*"([^"]+)"').firstMatch(cleaned);
      final audMatch =
          RegExp(r'"audience"\s*:\s*"([^"]+)"').firstMatch(cleaned);
      final prepMatch =
          RegExp(r'"preparation"\s*:\s*"([^"]+)"').firstMatch(cleaned);

      if (descMatch != null || topicMatch != null) {
        return AiEventSuggestion(
          topic: topicMatch?.group(1) ?? '',
          description: descMatch?.group(1) ?? cleaned,
          audience: audMatch?.group(1) ?? '',
          preparation: prepMatch?.group(1) ?? '',
          activities: const [],
        );
      }
    }

    // Default graceful wrap if plain text
    return AiEventSuggestion(
      topic: '',
      description: cleaned,
      audience: '',
      preparation: '',
      activities: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'description': description,
        'audience': audience,
        'preparation': preparation,
        'activities': activities,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiEventSuggestion &&
          runtimeType == other.runtimeType &&
          topic == other.topic &&
          description == other.description &&
          audience == other.audience &&
          preparation == other.preparation;

  @override
  int get hashCode => Object.hash(topic, description, audience, preparation);
}
