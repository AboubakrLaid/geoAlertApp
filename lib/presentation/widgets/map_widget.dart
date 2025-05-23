import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/presentation/providers/zone_provider.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MapWidget extends ConsumerStatefulWidget {
  final Alert alert;
  const MapWidget({super.key, required this.alert});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> with SingleTickerProviderStateMixin {
  LatLng? userLocation;
  late MapController mapController;
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  LatLngBounds? bounds;

  double _currentZoom = 10.0;

  String loadingState = 'Initializing...';
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(animationController);

    // Initialize after the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialize();
    });
  }

  Future<void> _initialize() async {
    setState(() => loadingState = "Getting your location...");
    await _getUserLocation();

    setState(() => loadingState = "Fetching zone data...");
    await _fetchAlertZone();

    setState(() => loadingState = "Calculating fit zoom...");
    _fitBoundsToZoneAndUser();

    setState(() => isMapReady = true);
    if (mounted) {
      // Wait for the map to be ready before fitting the camera
      await Future.delayed(const Duration(milliseconds: 100));
      _fitCameraToBounds();
    }
  }

  Future<void> _getUserLocation() async {
    final geoLocator = geo.GeolocatorPlatform.instance;
    final x = await geoLocator.getCurrentPosition(locationSettings: geo.LocationSettings(accuracy: geo.LocationAccuracy.high));
    setState(() {
      userLocation = LatLng(x.latitude, x.longitude);
    });
  }

  Future<void> _fetchAlertZone() async {
    final notifier = ref.read(zoneProvider.notifier);
    await notifier.fetchZone(idAlert: widget.alert.alertId);
  }

  void _fitBoundsToZoneAndUser() {
    // Check if the map has been rendered first
    if (userLocation != null) {
      final zone = ref.read(zoneProvider).value;
      if (zone == null) return;

      final zonePoints = zone.coordinates.map((c) => LatLng(c.latitude, c.longitude)).toList();
      final allPoints = [...zonePoints, userLocation!];
      bounds = LatLngBounds.fromPoints(allPoints);

      // mapController.fitCamera(CameraFit.bounds(bounds: bounds!, padding: const EdgeInsets.all(60)));
    }
  }

  void _fitCameraToBounds() {
    if (bounds != null) {
      mapController.fitCamera(CameraFit.bounds(bounds: bounds!, padding: const EdgeInsets.all(60)));
    }
  }

  bool _isUserInsideZone(List<LatLng> polygonPoints, LatLng userPoint) {
    int i, j = polygonPoints.length - 1;
    bool inside = false;

    for (i = 0; i < polygonPoints.length; j = i++) {
      if ((polygonPoints[i].longitude > userPoint.longitude) != (polygonPoints[j].longitude > userPoint.longitude) &&
          (userPoint.latitude <
              (polygonPoints[j].latitude - polygonPoints[i].latitude) * (userPoint.longitude - polygonPoints[i].longitude) / (polygonPoints[j].longitude - polygonPoints[i].longitude) +
                  polygonPoints[i].latitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _checkIfSafe(List<LatLng> zonePoints) {
    if (userLocation == null) return;

    final isInside = _isUserInsideZone(zonePoints, userLocation!);
    final text = isInside ? 'You are inside the danger zone!' : 'You are safe!';
    final color = isInside ? const Color.fromRGBO(220, 9, 26, 1) : Colors.green;

    _fitCameraToBounds();
    CustomSnackBar.show(context, message: text, backgroundColor: color);
  }

  void _pointUserLocation() {
    if (userLocation != null) {
      mapController.move(userLocation!, 15);
      _blinkUserLocation();
    }
  }

  void _blinkUserLocation() async {
    for (int i = 0; i < 5; i++) {
      await animationController.forward();
      await Future.delayed(const Duration(milliseconds: 150));
      await animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    mapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zone = ref.watch(zoneProvider).value;

    if (!isMapReady) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.alert.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const CircularProgressIndicator(), const SizedBox(height: 20), Text(loadingState, style: const TextStyle(fontSize: 16))],
          ),
        ),
      );
    }

    final zonePoints = zone?.coordinates.map((c) => LatLng(c.latitude, c.longitude)).toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.alert.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(35.200, -0.600),
              initialZoom: 10,
              onPositionChanged: (MapCamera position, bool hasGesture) {
                setState(() => _currentZoom = position.zoom);
              },
            ),
            children: [
              TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.app'),
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          double baseSize = 12;
                          double markerSize = baseSize * (_currentZoom / 10).clamp(0.7, 2.5);
                          return Opacity(
                            opacity: opacityAnimation.value,
                            child: SizedBox(
                              width: markerSize + 8,
                              height: markerSize + 8,
                              child: Center(
                                child: Container(
                                  width: markerSize + 6,
                                  height: markerSize + 6,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                  child: Center(child: Container(width: markerSize, height: markerSize, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(220, 9, 26, 1)))),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              PolygonLayer(
                polygons: [
                  if (zonePoints.isNotEmpty)
                    Polygon(points: zonePoints, color: _getZoneColor(widget.alert.severity).withOpacity(0.1), borderColor: _getZoneColor(widget.alert.severity), borderStrokeWidth: 2),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              icon: Icons.menu,
              activeIcon: Icons.close,
              backgroundColor: const Color(0xFFDC091A),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.shield),
                  label: 'Am I Safe?',
                  onTap: () {
                    if (zonePoints.isNotEmpty && userLocation != null) {
                      _checkIfSafe(zonePoints);
                    }
                  },
                ),
                SpeedDialChild(child: const Icon(Icons.my_location), label: 'Point Me', onTap: _pointUserLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getZoneColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.minor:
        return const Color(0xFF22A447);
      case AlertSeverity.moderate:
        return const Color(0xFFFBA23C);
      case AlertSeverity.severe:
        return const Color(0xFFDC091A);
      default:
        return const Color(0xFF252525);
    }
  }
}
