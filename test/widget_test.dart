import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app.dart';

void main() {
  testWidgets('Mapbox token 안내 화면을 표시한다', (tester) async {
    await tester.pumpWidget(const PulseApp(mapboxAccessToken: ''));

    expect(find.text('Pulse'), findsOneWidget);
    expect(find.textContaining('Mapbox public access token'), findsOneWidget);
    expect(find.textContaining('--dart-define=ACCESS_TOKEN'), findsOneWidget);
  });
}
