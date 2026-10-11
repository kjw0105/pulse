class PulsePost {
  const PulsePost({
    required this.id,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.expiresAt,
  });

  static const maxMessageLength = 40;

  final String id;
  final String message;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? expiresAt;

  factory PulsePost.fromJson(Map<String, dynamic> json) {
    return PulsePost(
      id: json['id'] as String,
      message: (json['message'] ?? json['content']) as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String).toLocal(),
    );
  }
}
