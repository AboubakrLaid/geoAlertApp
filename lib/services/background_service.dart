import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geoalert/main.dart';

class BackgroundServiceManager {
  static final BackgroundServiceManager _instance = BackgroundServiceManager._internal();
  factory BackgroundServiceManager() => _instance;
  BackgroundServiceManager._internal();

  Future<void> startService() async {
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      await initializeService();
      await service.startService();
    }
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
  }

  Future<void> restartService() async {
    await stopService();
    await Future.delayed(Duration(seconds: 1)); // Ensure clean stop
    await startService();
  }
}
