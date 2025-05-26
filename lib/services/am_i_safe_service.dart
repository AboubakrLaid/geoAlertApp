import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart' as geo;

Future<void> initializeTrackingService() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final service = FlutterBackgroundService();

  if (await service.isRunning()) {
    service.invoke("stopTracking");
    await Future.delayed(Duration(seconds: 1));
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(autoStart: true, onStart: onTrack, isForegroundMode: true),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onTrack),
  );

  service.invoke("startService", {"title": "Tracking started", "content": "Your location is being tracked."});
}

@pragma('vm:entry-point')
void onTrack(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final geoLocator = geo.GeolocatorPlatform.instance;

  Timer.periodic(Duration(seconds: 5), (timer) async {
    if (service is! AndroidServiceInstance || !(await service.isForegroundService())) return;

    final position = await geoLocator.getCurrentPosition();
    print("Tracking position: ${position.latitude}, ${position.longitude}");

    service.setForegroundNotificationInfo(title: "Tracking 📍", content: "Current location: (${position.latitude}, ${position.longitude})");

    // Optional: Send to backend here
  });

  service.on("stopTracking").listen((event) {
    service.stopSelf();
  });
}
