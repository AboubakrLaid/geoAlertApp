import 'dart:async';
import 'dart:io';
import 'dart:ui';

// import 'package:fcm_test/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/config/app_config.dart';
import 'package:geoalert/config/app_theme.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/repositories/location_update_settings_repository_impl.dart';
import 'package:geoalert/domain/entities/location_update_settings.dart';
import 'package:geoalert/domain/usecases/fetch_location_update_frequency_usecase.dart';
import 'package:geoalert/domain/usecases/send_current_location_usecase.dart';
import 'package:geoalert/firebase_options.dart';
import 'package:geoalert/presentation/util/dialog_util.dart';
import 'package:geoalert/presentation/util/location_service_listener.dart';
import 'package:geoalert/routes/app_router.dart';
// import 'package:geoalert/services/am_i_safe_service.dart';
import 'package:geoalert/services/notification_service.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:toastification/toastification.dart';
import 'routes/routes.dart';

final resetAppProvider = Provider<VoidCallback>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if (await service.isRunning()) {
    service.invoke("stopService");
    await Future.delayed(Duration(seconds: 1)); // Ensure clean stop
  }
  // print("Srv initializing...");
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'GeoAlert',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground),
  );
  // print("Srv initialized");
  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final apiClient = ApiClient();
  final repository = LocationUpdateSettingsRepositoryImpl(apiClient);
  final getFrequencyUseCase = GetLocationUpdateSettingsUseCase(repository);
  final sendLocationUseCase = SendCurrentLocationUseCase(repository);
  final geoLocator = geo.GeolocatorPlatform.instance;

  service.on("stopService").listen((event) async {
    await service.stopSelf();
  });

  bool isUsingFakeCoordinates = await LocalStorage.instance.getUsingFakeCoordinates() ?? false;
  while (true) {
    final cycleStartTime = DateTime.now();

    try {
      // 1. Get user ID first (fail fast if not available)
      final userId = await LocalStorage.instance.getUserId();
      if (userId == null) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(title: "GeoAlert Service", content: "Waiting for login...");
        }
        await Future.delayed(Duration(seconds: 30));
        continue;
      }
      // print("Srv getting location for user: $userId");
      // 2. Execute parallel operations with timeouts
      final results = await Future.wait([
        isUsingFakeCoordinates ? LocalStorage.instance.getFakeCoordinates() : geoLocator.getCurrentPosition(locationSettings: geo.LocationSettings(accuracy: geo.LocationAccuracy.best)),
        getFrequencyUseCase.execute().timeout(Duration(seconds: 10)),
      ]);
      final position = results[0] as geo.Position;
      print("Position: ${position.latitude}, ${position.longitude}");
      final settings = results[1] as LocationUpdateSettings?;
      final frequency = settings?.frequency ?? 10;

      // print("Srv got location: ${position.latitude}, ${position.longitude}");
      // 3. Fire-and-forget the location send (don't wait for completion)
      unawaited(sendLocationUseCase.execute(userId: userId, latitude: position.latitude, longitude: position.longitude).catchError((e) => print('Send location error: $e')));
      // print('Location sent: ${position.latitude}, ${position.longitude}');
      // 4. Update notification
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(title: "GeoAlert", content: "Location updated at ${Jiffy.parseFromDateTime(DateTime.now()).yMMMMEEEEdjm}");
      }

      // 5. Calculate precise delay to maintain frequency
      final elapsedSeconds = DateTime.now().difference(cycleStartTime).inSeconds;
      final remainingDelay = frequency - elapsedSeconds;

      if (remainingDelay > 0) {
        await Future.delayed(Duration(seconds: remainingDelay));
      } else {
        // print('Cycle took longer than frequency ($elapsedSeconds > $frequency)');
      }
      // print("Srv cycle completed");
    } catch (e) {
      // print('Service error: $e\n$st');
      await Future.delayed(Duration(seconds: 10));
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// Future<void> requestPermissions() async {
//   // Request location permissions
//   final locationStatus = await perm.Permission.locationWhenInUse.request();
//   if (locationStatus.isGranted) {
//     await perm.Permission.locationAlways.request();
//   }

//   // Request notification permission for Android
//   if (Platform.isAndroid) {
//     final notificationStatus = await perm.Permission.notification.status;
//     if (notificationStatus.isDenied) {
//       await perm.Permission.notification.request();
//     }
//   }

//   // For Android 12+ exact alarms
//   if (Platform.isAndroid && await perm.Permission.accessNotificationPolicy.isDenied) {
//     await perm.Permission.accessNotificationPolicy.request();
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final accessToken = await LocalStorage.instance.getAccessToken();

  if (accessToken != null && accessToken.isNotEmpty) {
    await initializeService();
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  await Jiffy.setLocale('en');

  print("Access Token: $accessToken");

  final baseUrl = await LocalStorage.instance.getBaseUrl();
  if (baseUrl != null && baseUrl.isNotEmpty) {
    AppConfig.baseUrl = baseUrl;
  }
  print("Base URL: ${AppConfig.baseUrl}");

  runApp(MyApp());
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
    final notificationGranted = await _handleNotificationPermission();
    if (!notificationGranted) {
      _closeApp();
      return '';
    }

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

  Future<bool> _handleNotificationPermission() async {
    if (Platform.isAndroid) {
      // For Android 13+
      if (await perm.Permission.notification.isDenied) {
        final userAccepted = await _showEnableNotificationDialog(context);
        if (!userAccepted) return false;

        final status = await perm.Permission.notification.request();
        return status.isGranted;
      }
      return true;
    }
    return true; // For iOS, notification permission is handled differently
  }

  Future<bool> _showEnableLocationDialog(BuildContext context) async {
    if (!mounted || _isDialogShowing) return false;

    _isDialogShowing = true;

    final result = await buildEnableLocationDialog(context);

    _isDialogShowing = false;

    return result ?? false;
  }

  Future<bool> _showEnableNotificationDialog(BuildContext context) async {
    if (!mounted || _isDialogShowing) return false;

    _isDialogShowing = true;

    final result = await buildEnableNotificationDialog(context);

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

  Key _providerScopeKey = UniqueKey();

  void _resetAppState() {
    setState(() {
      _providerScopeKey = UniqueKey(); // rebuilds ProviderScope
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _providerScopeKey,
      overrides: [resetAppProvider.overrideWithValue(_resetAppState)],
      child: ToastificationWrapper(
        child: MaterialApp(
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
        ),
      ),
    );
  }
}
