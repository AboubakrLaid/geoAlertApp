import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/domain/entities/coordinate.dart';
import 'package:geoalert/domain/entities/zzone.dart';
import 'package:geoalert/presentation/providers/zone_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:latlong2/latlong.dart';

class ZonePage extends ConsumerStatefulWidget {
  const ZonePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ZonePageState();
}

class _ZonePageState extends ConsumerState<ZonePage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool showOptions = false;
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

  late AnimationController panelAnimationController;
  late Animation<Offset> panelSlideAnimation;
  late Animation<double> panelFadeAnimation;
  final MapController _mapController = MapController();
  double _currentZoom = 10.0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(animationController);

    panelAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    panelSlideAnimation = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(CurvedAnimation(parent: panelAnimationController, curve: Curves.easeOut));
    panelFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: panelAnimationController, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getZones();
      }
    });
  }

  Future<void> _getZones() async {
    final notifier = ref.read(zonesProvider.notifier);
    await notifier.fetchZones();
  }

  void _moveToZoneCenter(Zzone zone) {
    if (zone.coordinates.isEmpty) return;

    // calcuate zoom based on the size of the zone
    final latitudes = zone.coordinates.map((c) => c.latitude).toList();
    final longitudes = zone.coordinates.map((c) => c.longitude).toList();

    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final southWest = LatLng(minLat, minLng);
    final northEast = LatLng(maxLat, maxLng);

    final bounds = LatLngBounds(southWest, northEast);

    // Animate the map to fit the bounds with padding
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)));
  }

  void _showZonePicker(BuildContext context, List<Zzone> zones) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          itemCount: zones.length,
          // separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final zone = zones[index];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(zone.name, style: const TextStyle(fontFamily: "Space Grotesk", fontSize: 16, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.of(context).pop(); // close modal
                _moveToZoneCenter(zone);
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    panelAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final zonesState = ref.watch(zonesProvider);

    return Scaffold(
      body: zonesState.when(
        data: (zones) {
          final zonePolygons =
              zones.where((z) => z.coordinates.isNotEmpty).map((z) {
                final StrokePattern pattern = z.isActive ? StrokePattern.solid() : StrokePattern.dashed(segments: [7, 7]);
                final color = !z.isActive ? const Color.fromRGBO(108, 108, 108, 0.3) : const Color.fromRGBO(220, 9, 26, 0.5);
                final borderColor = !z.isActive ? const Color.fromRGBO(108, 108, 108, 0.6) : const Color.fromRGBO(220, 9, 26, 1);
                return Polygon(points: z.coordinates.map((c) => LatLng(c.latitude, c.longitude)).toList(), color: color, borderStrokeWidth: 2, borderColor: borderColor, pattern: pattern);
              }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(35.2, -0.6),
                  initialZoom: _currentZoom,
                  onPositionChanged: (position, hasGesture) {
                    setState(() => _currentZoom = position.zoom);
                  },
                ),
                children: [TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.app'), PolygonLayer(polygons: zonePolygons)],
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))]),
                  child: Text("${zones.length} Total Zones", style: TextStyle(fontFamily: "Space Grotesk", fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                ),
              ),

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
                                _optionBox(Icons.refresh_outlined, "Refresh", () {
                                  _getZones();
                                  showOptions = false;
                                }),
                                const SizedBox(height: 16),
                                _optionBox(Icons.search_outlined, "Locate Zone", () {
                                  setState(() {
                                    showOptions = false;
                                    panelAnimationController.reverse();
                                  });
                                  _showZonePicker(context, zones);
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const Text('Failed to load zones'), const SizedBox(height: 16), ElevatedButton(onPressed: _getZones, child: const Text('Retry'))],
              ),
            ),
      ),
      // floatingActionButton: zonesState.maybeWhen(
      //   data: (zones) {
      //     return SpeedDial(
      //       icon: Icons.menu,
      //       activeIcon: Icons.close,
      //       backgroundColor: Colors.blue,
      //       children: [
      //         SpeedDialChild(label: 'Total Zones: ${zones.length}', child: const Icon(Icons.info_outline), backgroundColor: Colors.green),
      //         SpeedDialChild(label: 'Locate a Zone', child: const Icon(Icons.search), backgroundColor: Colors.orange, onTap: () => _showZonePicker(context, zones)),
      //         SpeedDialChild(label: 'Refresh Zones', child: const Icon(Icons.refresh), backgroundColor: Colors.cyan, onTap: _getZones),
      //       ],
      //     );
      //   },
      //   orElse: () => null,
      // ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
