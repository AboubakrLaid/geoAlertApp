import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geoalert/main.dart';

class BackgroundServiceManager {
  static final BackgroundServiceManager _instance = BackgroundServiceManager._internal();
  factory BackgroundServiceManager() => _instance;
  BackgroundServiceManager._internal();

  Future<void> _ensureServiceStopped() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
      // Wait for service to fully stop
      await Future.delayed(const Duration(seconds: 2));
      try {
        // await service.stopBackgroundService();
      } catch (e) {
        print("Error stopping service: $e");
      }
    }
  }

  Future<void> startService() async {
    await _ensureServiceStopped();

    // Initialize fresh service
    await initializeService();

    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> stopService() async {
    await _ensureServiceStopped();
  }

  Future<void> restartService() async {
    await stopService();
    await Future.delayed(const Duration(seconds: 1));
    await startService();
  }
}
