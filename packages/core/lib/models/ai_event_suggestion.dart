import 'dart:convert';

import '../utils/ai_content_privacy.dart';

/// Level 2 Structured AI suggestion model for event content drafting.
/// Validates structured fields and screens suspected personal data locally.
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
    const fields = {
      'topic',
      'description',
      'audience',
      'preparation',
      'activities',
    };
    if (json.length != fields.length || !json.keys.every(fields.contains)) {
      throw const FormatException('Unexpected AI fields');
    }
    String field(String key, int max) {
      final value = json[key];
      if (value is! String ||
          value.trim().isEmpty ||
          value.length > max ||
          AiContentPrivacy.containsPersonalData(value)) {
        throw const FormatException('Invalid AI field');
      }
      return value.trim();
    }

    final activities = json['activities'];
    if (activities is! List ||
        activities.isEmpty ||
        activities.length > 8 ||
        activities.any(
          (v) =>
              v is! String ||
              v.trim().isEmpty ||
              v.length > 300 ||
              AiContentPrivacy.containsPersonalData(v),
        )) {
      throw const FormatException('Invalid AI activities');
    }
    return AiEventSuggestion(
      topic: field('topic', 80),
      description: field('description', 3000),
      audience: field('audience', 500),
      preparation: field('preparation', 1000),
      activities: List<String>.unmodifiable(
        activities.cast<String>().map((v) => v.trim()),
      ),
    );
  }
  factory AiEventSuggestion.fromRawText(String text) {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>)
      throw const FormatException('Expected JSON object');
    return AiEventSuggestion.fromJson(decoded);
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
          preparation == other.preparation &&
          activities.length == other.activities.length &&
          List.generate(
            activities.length,
            (i) => activities[i] == other.activities[i],
          ).every((same) => same);

  @override
  int get hashCode => Object.hash(
    topic,
    description,
    audience,
    preparation,
    Object.hashAll(activities),
  );
}
