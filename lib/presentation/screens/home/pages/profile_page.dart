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
        GoRouter.of(context).go(Routes.login);
        await LocalStorage.instance.setAccessToken('');
        await LocalStorage.instance.setRefreshToken('');
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke("stopService");
        }

        final manager = BackgroundServiceManager();
        await manager.stopService();
      });
    }

    return Scaffold(
      body: Column(
        children: [
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
    );
  }

  // Function to show the warning dialog
  void showWarningDialog(BuildContext context, Function onProceed) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(249, 250, 251, 1), // Background color of the pop-up
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 21),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Placeholder for the image at the top
                SizedBox(
                  height: 120, // Set a height for the image placeholder
                  // width: 64,
                  child: Image.asset('assets/images/question-mark.png', fit: BoxFit.fill),
                ),
                const SizedBox(height: 16),

                // Text asking the user if they are sure
                const Text('Are you sure?', style: TextStyle(fontFamily: 'Titillium Web', fontWeight: FontWeight.w700, fontSize: 21)),
                const SizedBox(height: 16),

                // Explanation text below the title
                const Text(
                  "Proceeding with logout will disconnect your location from the service, potentially causing you to miss important danger zone notifications.",
                  style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Red cancel button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: Size(double.infinity, 0), // Expand horizontally
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 16),

                // White proceed button
                ElevatedButton(
                  onPressed: () {
                    onProceed();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: Size(double.infinity, 0), // Expand horizontally
                    // side: const BorderSide(color: Colors.white), // Border for the white button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Yes', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
