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

class _ZonePageState extends ConsumerState<ZonePage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  double _currentZoom = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getZones());
  }

  Future<void> _getZones() async {
    final notifier = ref.read(zonesProvider.notifier);
    await notifier.fetchZones();
  }

  void _moveToZoneCenter(Zzone zone) {
    if (zone.coordinates.isEmpty) return;

    final center = _calculateCenter(zone.coordinates);
    _mapController.move(center, _currentZoom);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to zone: ${zone.name}')));
  }

  LatLng _calculateCenter(List<Coordinate> coords) {
    final latitudes = coords.map((c) => c.latitude);
    final longitudes = coords.map((c) => c.longitude);
    return LatLng(latitudes.reduce((a, b) => a + b) / coords.length, longitudes.reduce((a, b) => a + b) / coords.length);
  }

  void _showZonePicker(BuildContext context, List<Zzone> zones) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.separated(
          itemCount: zones.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final zone = zones[index];
            return ListTile(
              leading: const Icon(Icons.place),
              title: Text(zone.name),
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
      floatingActionButton: zonesState.maybeWhen(
        data: (zones) {
          return SpeedDial(
            icon: Icons.menu,
            activeIcon: Icons.close,
            backgroundColor: Colors.blue,
            children: [
              SpeedDialChild(label: 'Total Zones: ${zones.length}', child: const Icon(Icons.info_outline), backgroundColor: Colors.green),
              SpeedDialChild(label: 'Locate a Zone', child: const Icon(Icons.search), backgroundColor: Colors.orange, onTap: () => _showZonePicker(context, zones)),
              SpeedDialChild(label: 'Refresh Zones', child: const Icon(Icons.refresh), backgroundColor: Colors.cyan, onTap: _getZones),
            ],
          );
        },
        orElse: () => null,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
