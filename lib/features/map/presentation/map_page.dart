import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../models/geo_point.dart';
import '../../../models/pulse_post.dart';
import '../../../services/location_service.dart';
import '../domain/pulse_repository.dart';
import 'map_controller.dart';
import 'widgets/compose_pulse_sheet.dart';
import 'widgets/token_required_view.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    required this.hasMapboxAccessToken,
    required this.repository,
    required this.locationService,
    super.key,
  });

  final bool hasMapboxAccessToken;
  final PulseRepository repository;
  final LocationService locationService;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final PulseMapController _controller;
  MapboxMap? _map;
  PointAnnotationManager? _annotationManager;
  Timer? _floatTimer;
  double _floatPhase = 0;
  bool _isSyncing = false;
  bool _syncAgain = false;
  GeoPoint? _lastCameraCenter;
  LocationFailure? _shownFailure;

  @override
  void initState() {
    super.initState();
    _controller = PulseMapController(
      repository: widget.repository,
      locationService: widget.locationService,
    )..addListener(_onControllerChanged);
    if (widget.hasMapboxAccessToken) {
      unawaited(_controller.initialize());
    }
  }

  @override
  void dispose() {
    _floatTimer?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    unawaited(_syncAnnotations());

    final location = _controller.currentLocation;
    if (location != null && location != _lastCameraCenter) {
      _lastCameraCenter = location;
      unawaited(_centerMap(location));
      unawaited(_enableLocationPuck());
    }

    final failure = _controller.locationFailure;
    if (failure != null && failure != _shownFailure) {
      _shownFailure = failure;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showLocationError(failure),
      );
    }
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    _annotationManager = await map.annotations.createPointAnnotationManager();
    await _annotationManager!.setTextAllowOverlap(false);
    await _annotationManager!.setTextIgnorePlacement(false);
    await _syncAnnotations();
    _startFloatingAnimation();
  }

  Future<void> _syncAnnotations() async {
    final manager = _annotationManager;
    if (manager == null) return;
    if (_isSyncing) {
      _syncAgain = true;
      return;
    }

    _isSyncing = true;
    do {
      _syncAgain = false;
      final posts = List<PulsePost>.of(_controller.posts);
      await manager.deleteAll();
      if (posts.isNotEmpty) {
        await manager.createMulti(posts.map(_annotationFor).toList());
      }
    } while (_syncAgain && mounted);
    _isSyncing = false;
  }

  PointAnnotationOptions _annotationFor(PulsePost post) {
    return PointAnnotationOptions(
      geometry: Point(coordinates: Position(post.longitude, post.latitude)),
      textField: post.message,
      textSize: 14,
      textColor: 0xFFF2F5EF,
      textHaloColor: 0xE6111419,
      textHaloWidth: 2.2,
      textHaloBlur: 0.8,
      textLetterSpacing: 0.02,
      textMaxWidth: 16,
      textOffset: const [0, 0],
      textAnchor: TextAnchor.CENTER,
      customData: {'id': post.id},
    );
  }

  void _startFloatingAnimation() {
    _floatTimer?.cancel();
    _floatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final manager = _annotationManager;
      if (manager == null) return;
      _floatPhase += 0.12;
      final offset = math.sin(_floatPhase) * 0.09;
      unawaited(manager.setTextOffset([0, offset]));
    });
  }

  Future<void> _centerMap(GeoPoint point) async {
    await _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(point.longitude, point.latitude)),
        zoom: 14.4,
        pitch: 20,
      ),
      MapAnimationOptions(duration: 900),
    );
  }

  Future<void> _enableLocationPuck() async {
    await _map?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: 0xFFB6FF69,
        showAccuracyRing: true,
      ),
    );
  }

  void _showLocationError(LocationFailure failure) {
    if (!mounted) return;
    final message = switch (failure) {
      LocationFailure.serviceDisabled => '위치 서비스가 꺼져 있어 서울 중심으로 표시합니다.',
      LocationFailure.permissionDenied => '위치 권한이 없어 서울 중심으로 표시합니다.',
      LocationFailure.permissionDeniedForever => '설정에서 위치 권한을 허용해 주세요.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: failure == LocationFailure.permissionDeniedForever
            ? SnackBarAction(
                label: '설정',
                onPressed: widget.locationService.openAppSettings,
              )
            : null,
      ),
    );
  }

  Future<void> _openComposer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ComposePulseSheet(onSubmit: _controller.submit),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasMapboxAccessToken) {
      return const Scaffold(body: TokenRequiredView());
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapWidget(
            key: const ValueKey('pulse-map'),
            styleUri: MapboxStyles.DARK,
            viewport: CameraViewportState(
              center: Point(
                coordinates: Position(
                  PulseMapController.fallbackCenter.longitude,
                  PulseMapController.fallbackCenter.latitude,
                ),
              ),
              zoom: 14.1,
              pitch: 20,
            ),
            onMapCreated: _onMapCreated,
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xB3090B0F),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xD9090B0F),
                  ],
                  stops: const [0, 0.2, 0.68, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _BrandPill(),
                      const Spacer(),
                      _RoundMapButton(
                        icon: Icons.my_location_rounded,
                        isLoading: _controller.isLocating,
                        onTap: _controller.locateUser,
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _openComposer,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        '한 문장 남기기',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xF2F2F5EF),
                        foregroundColor: const Color(0xFF10130E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC111419),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waves_rounded, size: 17, color: Color(0xFFB6FF69)),
          SizedBox(width: 8),
          Text(
            'Pulse',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC111419),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: SizedBox.square(
          dimension: 44,
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
