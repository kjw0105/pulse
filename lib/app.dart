import 'package:flutter/material.dart';

import 'features/map/data/sample_pulse_repository.dart';
import 'features/map/presentation/map_page.dart';
import 'services/location_service.dart';

class PulseApp extends StatelessWidget {
  const PulseApp({required this.mapboxAccessToken, super.key});

  final String mapboxAccessToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF090B0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB6FF69),
          brightness: Brightness.dark,
          surface: const Color(0xFF12151B),
        ),
        fontFamilyFallback: const ['Apple SD Gothic Neo', 'Noto Sans KR'],
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF12151B),
          modalBackgroundColor: Color(0xFF12151B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
      ),
      home: MapPage(
        hasMapboxAccessToken: mapboxAccessToken.isNotEmpty,
        repository: SamplePulseRepository(),
        locationService: LocationService(),
      ),
    );
  }
}
