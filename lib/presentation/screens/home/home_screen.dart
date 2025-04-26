import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/repositories/location_update_settings_repository_impl.dart';
import 'package:geoalert/domain/usecases/send_current_location_usecase.dart';
import 'package:geoalert/presentation/providers/location_update_provider.dart';
import 'package:geoalert/presentation/providers/test_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:geoalert/services/background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<int?> getUserId() async {
    return await LocalStorage.instance.getUserId();
  }

  void _callProtected() {
    ref.read(testProvider.notifier).callProtected().whenComplete(() async {
      final errorMessage = ref.read(testProvider).error.toString().toLowerCase();
      if (errorMessage.contains("Unauthorized. Please log in again.".toLowerCase())) {
        GoRouter.of(context).go(Routes.login);
        await BackgroundServiceManager().stopService();
      }
    });
  }

  void _getLocationFrequency() async {
    ref.read(locationUpdateNotifierProvider.notifier).loadFrequency();
  }

  Future<void> _sendLocation() async {
    final userId = await getUserId();
    if (userId == null) {
      CustomSnackBar.show(context, message: "User ID not found");
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomSnackBar.show(context, message: "Location services are disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackBar.show(context, message: "Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomSnackBar.show(context, message: "Location permissions are permanently denied");
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    await ref.read(locationUpdateNotifierProvider.notifier).sendLocation(userId: userId, latitude: position.latitude, longitude: position.longitude);

    CustomSnackBar.show(context, message: "Location sent!");
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(testProvider, (previous, next) {
      if (next.hasError) {
        final errorMessage = next.error.toString().toLowerCase();
        CustomSnackBar.show(context, message: errorMessage);
      }
    });

    final testState = ref.watch(testProvider);
    final locationState = ref.watch(locationUpdateNotifierProvider);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("Hello"),
          FutureBuilder(
            future: getUserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                return Text("User ID: ${snapshot.data}");
              } else {
                return const Text("No user ID");
              }
            },
          ),
          CustomElevatedButton(
            text: "Delete access token",
            onPressed: () async {
              await LocalStorage.instance.setAccessToken("");
              await LocalStorage.instance.setRefreshToken("");
            },
          ),
          CustomElevatedButton(text: "Call protected", onPressed: () => testState.isLoading ? null : _callProtected()),
          if (testState.hasValue) Text(testState.value ?? "No data", style: const TextStyle(color: Colors.green)),
          if (testState.hasError) Text(testState.error.toString(), style: const TextStyle(color: Colors.red)),
          CustomElevatedButton(text: "Get location frequency", onPressed: () => locationState.isLoading ? null : _getLocationFrequency()),
          if (locationState.isLoading) const CircularProgressIndicator(),
          if (locationState.hasValue) Text(locationState.value.toString(), style: const TextStyle(color: Colors.green)),

          const SizedBox(height: 20),
          CustomElevatedButton(text: "Send Location", onPressed: _sendLocation),
        ],
      ),
    );
  }
}

Future<bool> sendLocationInBackground() async {
  try {
    final apiClient = ApiClient(); // Manually instantiate
    final repo = LocationUpdateSettingsRepositoryImpl(apiClient);
    final usecase = SendCurrentLocationUseCase(repo);

    final userId = await LocalStorage.instance.getUserId();
    if (userId == null) throw Exception("User ID is null");

    final position = await Geolocator.getCurrentPosition();
    await usecase.execute(userId: userId, latitude: position.latitude, longitude: position.longitude);

    print("✅ Location sent in background");
    return true;
  } catch (e) {
    print("❌ Failed to send location in background: $e");
    return false;
  }
}
