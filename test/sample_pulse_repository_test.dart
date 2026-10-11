import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/map/data/sample_pulse_repository.dart';
import 'package:pulse/models/geo_point.dart';

void main() {
  test('샘플 게시글을 중심 좌표 주변에 반환하고 새 문장을 보관한다', () async {
    final repository = SamplePulseRepository();
    const center = GeoPoint(latitude: 37.5665, longitude: 126.9780);

    final initial = await repository.getNearby(center: center);
    expect(initial, hasLength(6));

    await repository.create(message: '테스트 문장', location: center);
    final updated = await repository.getNearby(center: center);

    expect(updated, hasLength(7));
    expect(updated.first.message, '테스트 문장');
  });
}
