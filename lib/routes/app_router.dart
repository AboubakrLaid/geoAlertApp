import 'package:geoalert/presentation/screens/auth/login_screen.dart';
import 'package:geoalert/presentation/screens/auth/register_screen.dart';
import 'package:geoalert/presentation/screens/confirm-email/confirm_email_screen.dart';
import 'package:geoalert/presentation/screens/home/home_screen.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final String initialLocation;

  AppRouter({required this.initialLocation});

  GoRouter get router {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return LoginScreen(email: email);
          },
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) {
            return RegisterScreen();
          },
        ),
        GoRoute(
          path: Routes.confirmEmail,
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return ConfirmEmailScreen(email: email);
          },
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
      ],
    );
  }
}
