import 'package:flutter/foundation.dart';

import '../../../models/geo_point.dart';
import '../../../models/pulse_post.dart';
import '../../../services/location_service.dart';
import '../domain/pulse_repository.dart';

class PulseMapController extends ChangeNotifier {
  PulseMapController({required this.repository, required this.locationService});

  static const fallbackCenter = GeoPoint(
    latitude: 37.5665,
    longitude: 126.9780,
  );

  final PulseRepository repository;
  final LocationService locationService;

  GeoPoint _center = fallbackCenter;
  GeoPoint? _currentLocation;
  List<PulsePost> _posts = const [];
  LocationFailure? _locationFailure;
  bool _isLocating = false;
  bool _isSubmitting = false;

  GeoPoint get center => _center;
  GeoPoint? get currentLocation => _currentLocation;
  List<PulsePost> get posts => List.unmodifiable(_posts);
  LocationFailure? get locationFailure => _locationFailure;
  bool get isLocating => _isLocating;
  bool get isSubmitting => _isSubmitting;

  Future<void> initialize() async {
    await _loadPosts();
    await locateUser();
  }

  Future<void> locateUser() async {
    _isLocating = true;
    _locationFailure = null;
    notifyListeners();

    try {
      final result = await locationService.getCurrentLocation();
      if (result.isSuccess) {
        _currentLocation = result.point;
        _center = result.point!;
        await _loadPosts();
      } else {
        _locationFailure = result.failure;
      }
    } catch (_) {
      _locationFailure = LocationFailure.serviceDisabled;
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<bool> submit(String message) async {
    final normalized = message.trim();
    if (normalized.isEmpty || normalized.length > PulsePost.maxMessageLength) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();
    try {
      await repository.create(
        message: normalized,
        location: _currentLocation ?? _center,
      );
      await _loadPosts();
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _loadPosts() async {
    _posts = await repository.getNearby(center: _center);
    notifyListeners();
  }
}
