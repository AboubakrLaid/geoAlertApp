import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/routes/app_router.dart';
import 'routes/routes.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialLocation() async {
    final token = await LocalStorage.instance.getAccessToken();
    return (token == null || token.isEmpty) ? Routes.login : Routes.home;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: Center(child: CircularProgressIndicator())));
        } else if (snapshot.hasError) {
          return MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: Center(child: Text("Error: ${snapshot.error}"))));
        } else if (snapshot.hasData) {
          return MaterialApp.router(
            theme: ThemeData(
              fontFamily: 'Space Grotesk',
              colorScheme: const ColorScheme.light(primary: Color.fromRGBO(220, 9, 26, 1)),

              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
            ),
            debugShowCheckedModeBanner: false,
            title: 'GeoAlert',
            routerConfig: AppRouter(initialLocation: snapshot.data!).router,
          );
        }
        return Container();
      },
    );
  }
}
