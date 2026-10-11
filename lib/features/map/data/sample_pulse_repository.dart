import '../../../models/geo_point.dart';
import '../../../models/pulse_post.dart';
import '../domain/pulse_repository.dart';

class SamplePulseRepository implements PulseRepository {
  final List<PulsePost> _userPosts = [];

  static const _samples = <String>[
    '오늘은 조금 천천히 걸어도 괜찮아',
    '이 골목의 밤공기가 유난히 좋다',
    '누군가에게 말하고 싶었던 하루',
    '생각보다 잘 버티고 있어',
    '작은 행운이 찾아오길',
    '여기서는 잠시 숨을 고르게 돼',
  ];

  static const _offsets = <(double, double)>[
    (0.0022, -0.0018),
    (-0.0015, 0.0024),
    (0.0035, 0.0028),
    (-0.0031, -0.0012),
    (0.0004, 0.0041),
    (-0.0040, 0.0030),
  ];

  @override
  Future<List<PulsePost>> getNearby({
    required GeoPoint center,
    double radiusKm = 3,
  }) async {
    final now = DateTime.now();
    final samplePosts = List.generate(_samples.length, (index) {
      final offset = _offsets[index];
      return PulsePost(
        id: 'sample-$index',
        message: _samples[index],
        latitude: center.latitude + offset.$1,
        longitude: center.longitude + offset.$2,
        createdAt: now.subtract(Duration(minutes: 8 + index * 13)),
      );
    });

    return [..._userPosts, ...samplePosts];
  }

  @override
  Future<PulsePost> create({
    required String message,
    required GeoPoint location,
  }) async {
    final post = PulsePost(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      message: message.trim(),
      latitude: location.latitude,
      longitude: location.longitude,
      createdAt: DateTime.now(),
    );
    _userPosts.insert(0, post);
    return post;
  }
}
