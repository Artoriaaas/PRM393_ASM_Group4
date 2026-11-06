class Club {
  const Club({
    required this.id,
    required this.name,
    this.shortName = '',
    this.description = '',
    this.status = 'active',
  });

  final String id;
  final String name;
  final String shortName;
  final String description;
  final String status;

  bool get isActive => status == 'active';

  factory Club.fromJson(String id, Map<String, dynamic> data) => Club(
        id: id,
        name: data['name'] as String? ?? '',
        shortName: data['shortName'] as String? ?? '',
        description: data['description'] as String? ?? '',
        status: data['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'shortName': shortName.trim(),
        'description': description.trim(),
        'status': status,
      };
}
