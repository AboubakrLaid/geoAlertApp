import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:geoalert/services/background_service.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Logout function
    void logout(BuildContext context) async {
      showWarningDialog(context, () async {
        // Proceed with logout actions after user acknowledges the warning
        await LocalStorage.instance.setAccessToken('');
        await LocalStorage.instance.setRefreshToken('');
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke("stopService");
        }

        final manager = BackgroundServiceManager();
        await manager.stopService();
        GoRouter.of(context).go(Routes.login);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(child: Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'TittilumWeb'))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () => logout(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 0), // Make button take full width
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'SpaceGrotesk')),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Function to show the warning dialog
  void showWarningDialog(BuildContext context, Function onProceed) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent dismiss by back button
          child: AlertDialog(
            title: Row(children: const [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 8), Text('Warning')]),
            content: const Text(
              'By proceeding with what you are doing, your current location won\'t be communicated with our service, '
              'thus you won\'t get updated notifications if you enter a danger zone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                  onProceed(); // Proceed with logout
                },
                child: const Text('Proceed'),
              ),
            ],
          ),
        );
      },
    );
  }
}
