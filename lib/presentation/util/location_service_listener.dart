import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geoalert/main.dart';
import 'package:geoalert/presentation/util/dialog_util.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationServiceListener {
  StreamSubscription<geo.ServiceStatus>? _subscription;
  bool _isDialogShowing = false;

  void start() {
    _subscription = geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) async {
      if (status == geo.ServiceStatus.disabled && !_isDialogShowing) {
        _isDialogShowing = true;

        final result = await buildEnableLocationDialog(navigatorKey.currentContext!);

        _isDialogShowing = false;

        if (result != true) {
          _closeApp();
        }
      }
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _closeApp() {
    if (Platform.isAndroid || Platform.isLinux) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }
}
