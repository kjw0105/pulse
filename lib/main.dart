import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const accessToken = String.fromEnvironment('ACCESS_TOKEN');
  if (accessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(accessToken);
  }

  runApp(const PulseApp(mapboxAccessToken: accessToken));
}
