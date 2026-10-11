import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'features/map/data/supabase_pulse_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const accessToken = String.fromEnvironment('ACCESS_TOKEN');
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (accessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(accessToken);
  }

  SupabasePulseRepository? repository;
  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
    repository = SupabasePulseRepository(client);
  }

  runApp(
    PulseApp(
      mapboxAccessToken: accessToken,
      repository: repository,
    ),
  );
}
