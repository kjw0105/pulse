class PulsePost {
  const PulsePost({
    required this.id,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  static const maxMessageLength = 40;

  final String id;
  final String message;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
}
