// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geoalert/config/app_theme.dart';
// import 'package:geoalert/core/storage/local_storage.dart';
// import 'package:geoalert/routes/app_router.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';
// import 'routes/routes.dart';
// import 'package:geolocator/geolocator.dart' as geo;
// import 'package:permission_handler/permission_handler.dart' as perm;

// void main() {
//   runApp(ProviderScope(child: MyApp()));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late StreamSubscription<geo.ServiceStatus> _locationServiceSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _locationServiceSubscription = Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
//       if (status == geo.ServiceStatus.disabled) {
//         _showEnableLocationDialog(context);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _locationServiceSubscription.cancel();
//     super.dispose();
//   }

//   Future<String> _initializeApp(BuildContext context) async {
//     final permission = await Permission.location.request();
//     if (permission.isDenied || permission.isPermanentlyDenied) {
//       _closeApp();
//       return '';
//     }

//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       bool userAccepted = await _showEnableLocationDialog(context);
//       if (userAccepted) {
//         await Geolocator.openLocationSettings();
//         await Future.delayed(const Duration(seconds: 2));
//         serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (!serviceEnabled) {
//           _closeApp();
//           return '';
//         }
//       } else {
//         _closeApp();
//         return '';
//       }
//     }

//     final token = await LocalStorage.instance.getAccessToken();
//     return (token == null || token.isEmpty) ? Routes.login : Routes.home;
//   }

//   Future<bool> _showEnableLocationDialog(BuildContext context) async {
//     if (!mounted) return false; // Prevent showing if widget is disposed
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text("Enable Location"),
//                 content: const Text("Location is required to use this app. Please enable it in your settings."),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(false);
//                       _closeApp();
//                     },
//                     child: const Text("Exit"),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(true);
//                       Geolocator.openLocationSettings();
//                     },
//                     child: const Text("Enable"),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }

//   static void _closeApp() {
//     if (Platform.isAndroid) {
//       SystemNavigator.pop();
//     } else {
//       exit(0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeConfig.themeData,
//       home: Builder(
//         builder:
//             (context) => FutureBuilder<String>(
//               future: _initializeApp(context),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Scaffold(body: Center(child: CircularProgressIndicator()));
//                 } else if (snapshot.hasError) {
//                   return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
//                 } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                   return MaterialApp.router(debugShowCheckedModeBanner: false, theme: ThemeConfig.themeData, routerConfig: AppRouter(initialLocation: snapshot.data!).router);
//                 }
//                 return const SizedBox(); // fallback
//               },
//             ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/config/app_theme.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/util/dialog_util.dart';
import 'package:geoalert/presentation/util/location_service_listener.dart';
import 'package:geoalert/routes/app_router.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:geolocator/geolocator.dart' as geo;
import 'routes/routes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StreamSubscription<geo.ServiceStatus> _locationServiceSubscription;
  final LocationServiceListener _locationServiceListener = LocationServiceListener();

  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationServiceListener.start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationServiceSubscription.cancel();
    _locationServiceListener.stop();
    super.dispose();
  }

  Future<String> _initializeApp(BuildContext context) async {
    final permission = await perm.Permission.location.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      _closeApp();
      return '';
    }

    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool userAccepted = await _showEnableLocationDialog(context);
      if (userAccepted) {
        await geo.Geolocator.openLocationSettings();
        await Future.delayed(const Duration(seconds: 2));
        serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _closeApp();
          return '';
        }
      } else {
        _closeApp();
        return '';
      }
    }

    final token = await LocalStorage.instance.getAccessToken();
    return (token == null || token.isEmpty) ? Routes.login : Routes.home;
  }

  Future<bool> _showEnableLocationDialog(BuildContext context) async {
    if (!mounted || _isDialogShowing) return false;

    _isDialogShowing = true;

    final result = await buildEnableLocationDialog(context);

    _isDialogShowing = false;

    return result ?? false;
  }

  static void _closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeConfig.themeData,
      home: Builder(
        builder:
            (context) => FutureBuilder<String>(
              future: _initializeApp(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return MaterialApp.router(debugShowCheckedModeBanner: false, theme: ThemeConfig.themeData, routerConfig: AppRouter(initialLocation: snapshot.data!).router);
                }
                return const SizedBox(); // fallback
              },
            ),
      ),
    );
  }
}
