import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/domain/entities/auth_tokens.dart';
import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/auth_repository.dart';
import 'package:geoalert/domain/usecases/login_usecase.dart';
import 'package:geoalert/domain/usecases/register_usecase.dart';
import 'package:geoalert/data/repositories/auth_repository_impl.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/main.dart';
import 'package:geoalert/presentation/providers/user_profile_provider.dart';
import 'package:geoalert/services/background_service.dart';

// Dependency Injection
final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(apiClientProvider));
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

// Auth State Provider
final authStateProvider = StateProvider<User?>((ref) => null);

// Auth Notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthTokens?>>((ref) {
  return AuthNotifier(ref.read(loginUseCaseProvider), ref.read(registerUseCaseProvider), ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthTokens?>> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final Ref _ref;

  AuthNotifier(this._loginUseCase, this._registerUseCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final tokens = await _loginUseCase.execute(email, password);
      state = AsyncValue.data(tokens);
      if (tokens != null) {
        await LocalStorage.instance.setAccessToken(tokens.accessToken);
        await LocalStorage.instance.setRefreshToken(tokens.refreshToken);

        await _ref.read(userNotifierProvider.notifier).fetchUser();
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke("stopService");
          await Future.delayed(Duration(seconds: 1)); // Ensure clean stop
        }

        // 3. Reinitialize and start fresh service
        await BackgroundServiceManager().restartService();
      }
    } catch (e) {
      print("Auth Notifier Error: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> register({required String firstName, required String lastName, required String email, required String phoneNumber, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _registerUseCase.execute(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // ✅ Reset the authentication state
  void resetState() {
    state = const AsyncValue.data(null);
  }
}
