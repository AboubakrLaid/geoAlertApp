import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/main.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:geoalert/services/background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logout function
    void logout(BuildContext context) async {
      showWarningDialog(context, () async {
        // Proceed with logout actions after user acknowledges the warning
        // clear all riverpod providers

        GoRouter.of(context).go(Routes.login);
        await LocalStorage.instance.setAccessToken('');
        await LocalStorage.instance.setRefreshToken('');
        // await LocalStorage.instance.setFakeCoordinates(0.0, 0.0);
        // await LocalStorage.instance.setUsingFakeCoordinates(false);
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke("stopService");
        }
        final reset = ref.read(resetAppProvider);
        reset();

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
          // add a switch to toggle fake location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {
                GoRouter.of(context).push(Routes.mapPicker);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 0), // Make button take full width
              ),
              child: const Text('Set fake coordinates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'SpaceGrotesk')),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {
                showCustomInputDialog(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 0), // Make button take full width
              ),
              child: const Text('Set base url', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'SpaceGrotesk')),
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

  void showCustomInputDialog(BuildContext context) {
    final TextEditingController hostController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(249, 250, 251, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 21),
            child: StatefulBuilder(
              builder: (context, setState) {
                // Async init block
                Future.microtask(() async {
                  final savedBaseUrl = await LocalStorage.instance.getBaseUrl();
                  if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
                    final host = savedBaseUrl.replaceAll('http://', '').replaceAll(':7777', '');
                    hostController.text = host;
                    setState(() {}); // Trigger UI update
                  }
                });

                hostController.addListener(() {
                  setState(() {});
                });

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 120, child: Image.asset('assets/images/question-mark.png', fit: BoxFit.fill)),
                      const SizedBox(height: 16),
                      const Text('Set Base URL', style: TextStyle(fontFamily: 'Titillium Web', fontWeight: FontWeight.w700, fontSize: 21)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hostController,
                        decoration: InputDecoration(
                          prefixIcon:
                              hostController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      hostController.clear();
                                      setState(() {});
                                    },
                                  )
                                  : null,
                          labelText: 'Host',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cancel button
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),

                      // Save base URL button
                      AbsorbPointer(
                        absorbing: hostController.text.isEmpty,

                        child: ElevatedButton(
                          onPressed: () async {
                            final baseUrl = "http://${hostController.text.trim()}:7777";
                            await LocalStorage.instance.setBaseUrl(baseUrl);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hostController.text.isEmpty ? Colors.grey : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Clear base URL button
                      ElevatedButton(
                        onPressed: () async {
                          await LocalStorage.instance.setBaseUrl('');
                          hostController.clear();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Clear Base URL', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
