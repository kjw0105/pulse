import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/geo_point.dart';
import '../../../models/pulse_post.dart';
import '../domain/pulse_repository.dart';

class SupabasePulseRepository implements PulseRepository {
  SupabasePulseRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<PulsePost>> getNearby({
    required GeoPoint center,
    double radiusKm = 3,
  }) async {
    final response = await client.rpc(
      'get_nearby_posts',
      params: {
        'p_latitude': center.latitude,
        'p_longitude': center.longitude,
        'p_radius_km': radiusKm,
      },
    );

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(PulsePost.fromJson).toList(growable: false);
  }

  @override
  Future<PulsePost> create({
    required String message,
    required GeoPoint location,
  }) async {
    final response = await client.rpc(
      'create_anonymous_post',
      params: {
        'p_content': message.trim(),
        'p_latitude': location.latitude,
        'p_longitude': location.longitude,
      },
    );

    final rows = List<Map<String, dynamic>>.from(response as List);
    if (rows.isEmpty) {
      throw StateError('Supabase did not return the created post.');
    }
    return PulsePost.fromJson(rows.single);
  }
}
