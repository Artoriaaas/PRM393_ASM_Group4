class CloudSettings {
  const CloudSettings({
    this.recommendationLimit = 10,
    this.showRecommendations = true,
  });
  final int recommendationLimit;
  final bool showRecommendations;
}

class PushTarget {
  const PushTarget({
    required this.path,
    this.uid,
    this.opened = false,
    this.message,
  });
  final String path;
  final String? uid;
  final bool opened;
  final String? message;
}
