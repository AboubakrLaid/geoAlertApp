import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/screens/auth/login_screen.dart';
import 'package:geoalert/presentation/screens/auth/register_screen.dart';
import 'package:geoalert/presentation/screens/confirm-email/confirm_email_screen.dart';
import 'package:geoalert/presentation/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: "/login", // Default path

  redirect: (context, state) async {
    final token = await LocalStorage.instance.getAccessToken();

    if (token == null || token.isEmpty) {
      if (state.fullPath != "/login") {
        return "/login";
      }
    } else {
      if (state.fullPath == "/login" || state.fullPath == "/register") {
        return "/home";
      }
    }

    return null; // No redirection needed
  },

  routes: [
    GoRoute(
      path: "/login",
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return LoginScreen(email: email);
      },
    ),

    GoRoute(
      path: "/register",
      builder: (context, state) {
        return RegisterScreen();
      },
    ),

    GoRoute(
      path: '/confirm-email',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ConfirmEmailScreen(email: email);
      },
    ),

    GoRoute(
      path: "/home",
      builder: (context, state) {
        return HomeScreen();
      },
    ),
  ],
);
