import '../../../models/geo_point.dart';
import '../../../models/pulse_post.dart';

abstract interface class PulseRepository {
  Future<List<PulsePost>> getNearby({
    required GeoPoint center,
    double radiusKm = 3,
  });

  Future<PulsePost> create({
    required String message,
    required GeoPoint location,
  });
}
