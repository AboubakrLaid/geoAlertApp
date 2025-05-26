import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/presentation/providers/zone_provider.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:toastification/toastification.dart';

class MapWidget extends ConsumerStatefulWidget {
  final Alert alert;
  const MapWidget({super.key, required this.alert});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> with TickerProviderStateMixin {
  LatLng? userLocation;
  late MapController mapController;
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

  late AnimationController panelAnimationController;
  late Animation<Offset> panelSlideAnimation;
  late Animation<double> panelFadeAnimation;

  bool showOptions = false;
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

    panelAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    panelSlideAnimation = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(CurvedAnimation(parent: panelAnimationController, curve: Curves.easeOut));
    panelFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: panelAnimationController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    setState(() => loadingState = "Getting your location...");
    await _getUserLocation();

    setState(() => loadingState = "Fetching zone data...");
    await _fetchAlertZone();

    setState(() => loadingState = "Calculating fit zoom...");
    _fitBoundsToZoneAndUser();

    setState(() => isMapReady = true);
    await Future.delayed(const Duration(milliseconds: 100));
    _fitCameraToBounds();
  }

  Future<void> _getUserLocation() async {
    final geoLocator = geo.GeolocatorPlatform.instance;
    final pos = await geoLocator.getCurrentPosition(locationSettings: geo.LocationSettings(accuracy: geo.LocationAccuracy.high));
    setState(() => userLocation = LatLng(pos.latitude, pos.longitude));
  }

  Future<void> _fetchAlertZone() async {
    final notifier = ref.read(zoneProvider.notifier);
    await notifier.fetchZone(idAlert: widget.alert.alertId);
  }

  void _fitBoundsToZoneAndUser() {
    if (userLocation != null) {
      final zone = ref.read(zoneProvider).value;
      if (zone == null) return;
      final zonePoints = zone.coordinates.map((c) => LatLng(c.latitude, c.longitude)).toList();
      final allPoints = [...zonePoints, userLocation!];
      bounds = LatLngBounds.fromPoints(allPoints);
    }
  }

  void _fitCameraToBounds() {
    if (bounds != null) {
      mapController.fitCamera(CameraFit.bounds(bounds: bounds!, padding: const EdgeInsets.all(60)));
    }
  }

  void _checkIfSafe(List<LatLng> zonePoints) {
    if (userLocation == null) return;

    final isInside = _isUserInsideZone(zonePoints, userLocation!);
    final title = !isInside ? "You are safe!" : "You are in danger!";
    final body = !isInside ? "This area is safe" : "This area is dangerous";
    final iconImage = isInside ? Image.asset('assets/images/alarm.png', width: 24, height: 24) : Image.asset('assets/images/shield.png', width: 24, height: 24);

    _fitCameraToBounds();
    toastification.show(
      type: isInside ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Center(child: Text(title, style: TextStyle(fontFamily: "TittilumWeb", fontWeight: FontWeight.w700, fontSize: 16))),
      description: Center(child: Text(body, style: TextStyle(fontFamily: "SpaceGrotesk", fontWeight: FontWeight.w400, fontSize: 12))),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),

      primaryColor: isInside ? const Color.fromRGBO(34, 164, 71, 1) : const Color.fromRGBO(220, 9, 26, 1),
      backgroundColor: Colors.white,
      // foregroundColor: Colors.black,
      icon: iconImage,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: EdgeInsets.symmetric(horizontal: 54),
      borderRadius: BorderRadius.circular(12),
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, onClose) {
          return IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 20, color: Color.fromRGBO(217, 217, 217, 1)));
        },
      ),
      closeOnClick: false,
    );
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
    panelAnimationController.dispose();
    mapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zone = ref.watch(zoneProvider).value;

    if (!isMapReady) {
      return Scaffold(
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

          /// Blur when active
          if (showOptions) Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: Container(color: Colors.black.withOpacity(0.1)))),

          /// Top-left container and its right-side options
          Positioned(
            top: 120,
            left: 50,
            child: GestureDetector(
              onTap: () {
                setState(() => showOptions = !showOptions);
                if (showOptions) {
                  panelAnimationController.forward();
                } else {
                  panelAnimationController.reverse();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: const Icon(Icons.more_vert_outlined, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 50,
            child: Row(
              children: [
                const SizedBox(width: 60),
                if (showOptions)
                  FadeTransition(
                    opacity: panelFadeAnimation,
                    child: SlideTransition(
                      position: panelSlideAnimation,
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _optionBox(Icons.location_searching_outlined, "My location", () {
                              _pointUserLocation();
                              setState(() {
                                showOptions = false;
                                panelAnimationController.reverse();
                              });
                            }),
                            const SizedBox(height: 16),
                            _optionBox(Icons.shield_outlined, "Safety check", () {
                              if (zonePoints.isNotEmpty && userLocation != null) {
                                _checkIfSafe(zonePoints);
                              }
                              setState(() {
                                showOptions = false;
                                panelAnimationController.reverse();
                              });
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Positioned(
          //   top: 120,
          //   left: 50,
          //   child: SpeedDial(
          //     icon: Icons.menu,
          //     activeIcon: Icons.close,
          //     direction: SpeedDialDirection.right,
          //     childrenButtonSize: Size(200, 200),
          //     backgroundColor: Colors.white,
          //     activeBackgroundColor: Colors.white,
          //     overlayColor: Colors.black.withOpacity(0.1),
          //     children: [
          //       SpeedDialChild(
          //         child: Column(
          //           children: [
          //             _optionBox(Icons.location_searching_outlined, "My location", () {
          //               if (userLocation != null) {
          //                 _pointUserLocation();
          //               } else {
          //                 CustomSnackBar.show(context, message: "Unable to get your location", backgroundColor: Colors.red);
          //               }
          //             }),
          //             _optionBox(Icons.shield_outlined, "Safety check", () {
          //               if (zonePoints.isNotEmpty && userLocation != null) {
          //                 _checkIfSafe(zonePoints);
          //               } else {
          //                 CustomSnackBar.show(context, message: "No zone data available", backgroundColor: Colors.red);
          //               }
          //             }),
          //           ],
          //         ),
          //         onTap: () {},
          //       ),
          //       // SpeedDialChild(child: const Icon(Icons.my_location), onTap: _pointUserLocation),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _optionBox(IconData icon, String label, VoidCallback onTap) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          GestureDetector(onTap: onTap, child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: "SpaceGrotesk", fontWeight: FontWeight.w400))),
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
