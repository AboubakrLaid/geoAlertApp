import 'package:flutter/material.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> _getToken() async {
    return await LocalStorage.instance.getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            },
          ),
        ],
      ),
    );
  }
}
