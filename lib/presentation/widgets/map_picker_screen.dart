import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/services/background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? tappedPoint;
  late MapController mapController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocalStorage.instance.getFakeCoordinates().then((coordinates) {
        if (coordinates != null) {
          setState(() {
            tappedPoint = LatLng(coordinates.latitude, coordinates.longitude);
            mapController.move(tappedPoint!, 12.0);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> onTap({required bool isUsingFakeCoordinates, double lat = 0.0, double lng = 0.0}) async {
    setState(() {
      isLoading = true;
    });
    await LocalStorage.instance.setUsingFakeCoordinates(isUsingFakeCoordinates);
    await LocalStorage.instance.setFakeCoordinates(lat, lng);
    BackgroundServiceManager backgroundServiceManager = BackgroundServiceManager();
    await backgroundServiceManager.restartService();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: const Text('Tap to Pick a Location'),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: tappedPoint ?? LatLng(35.6925560086809, -0.6809039431234322),
                initialZoom: 12.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    tappedPoint = point;
                    print("Tapped Point: ${tappedPoint!.latitude}, ${tappedPoint!.longitude}");
                  });
                },
              ),
              children: [
                TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.app'),
                if (tappedPoint != null) MarkerLayer(markers: [Marker(point: tappedPoint!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
              ],
            ),
          if (tappedPoint != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  await onTap(isUsingFakeCoordinates: true, lat: tappedPoint!.latitude, lng: tappedPoint!.longitude);
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm Location"),
              ),
            ),

          Positioned(
            bottom: 80,
            right: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () async {
                await onTap(isUsingFakeCoordinates: false);
                Navigator.of(context).pop();
              },
              child: const Text("Reset Location"),
            ),
          ),
        ],
      ),
    );
  }
}
