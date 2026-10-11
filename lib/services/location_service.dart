import 'package:geolocator/geolocator.dart';

import '../models/geo_point.dart';

enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationResult {
  const LocationResult.success(this.point) : failure = null;
  const LocationResult.failure(this.failure) : point = null;

  final GeoPoint? point;
  final LocationFailure? failure;

  bool get isSuccess => point != null;
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult.failure(LocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.failure(
        LocationFailure.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult.failure(LocationFailure.permissionDenied);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );
    return LocationResult.success(
      GeoPoint(latitude: position.latitude, longitude: position.longitude),
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
