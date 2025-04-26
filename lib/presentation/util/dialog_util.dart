import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:io';
import 'package:flutter/services.dart';

Future<bool?> buildEnableLocationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text("Enable Location"),
          content: const Text("Location is required to use this app. Please enable it in your settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                _closeApp();
              },
              child: const Text("Exit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                geo.Geolocator.openLocationSettings();
              },
              child: const Text("Enable"),
            ),
          ],
        ),
  );
}

Future<bool?> buildEnableNotificationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text("Enable Notifications"),
          content: const Text("Notifications are required to use this app. Please enable them in your settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                _closeApp();
              },
              child: const Text("Exit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Open notification settings
              },
              child: const Text("Enable"),
            ),
          ],
        ),
  );
}

void _closeApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}
