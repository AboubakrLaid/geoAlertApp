import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/providers/test_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<String?> _getToken() async {
    return await LocalStorage.instance.getAccessToken();
  }

  void _callProtected() {
    ref.read(testProvider.notifier).callProtected().whenComplete(() {
      final errorMessage = ref.read(testProvider).error.toString().toLowerCase();
      if (errorMessage.contains("Unauthorized. Please log in again.".toLowerCase())) {
        GoRouter.of(context).go(Routes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(testProvider, (previous, next) {
      if (next.hasError) {
        final errorMessage = next.error.toString().toLowerCase();
        // Handle error
        CustomSnackBar.show(context, message: errorMessage);
      }
    });
    final testState = ref.watch(testProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Hello"),
          Center(
            child: FutureBuilder<String?>(
              future: _getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(snapshot.data ?? 'No Token');
                }
              },
            ),
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
        ],
      ),
    );
  }
}
