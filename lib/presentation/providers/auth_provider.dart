import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/repositories/firebase_repository_impl.dart';
import 'package:geoalert/domain/entities/auth_tokens.dart';
import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/auth_repository.dart';
import 'package:geoalert/domain/usecases/login_usecase.dart';
import 'package:geoalert/domain/usecases/register_fcm_token_usecase.dart';
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
  Future<void> _restartAndConfigureService() async {
    final manager = BackgroundServiceManager();
    await manager.restartService();

    final apiClient = ApiClient();
    final fcmTokenRepository = FireBaseRepositoryImpl(apiClient);
    final registerFcmTokenUsecase = RegisterFcmTokenUsecase(fcmTokenRepository);
    final fcmToken = await LocalStorage.instance.getFcmToken();
    final userId = await LocalStorage.instance.getUserId();
    if (fcmToken != null && userId != null) {
      try {
        unawaited(registerFcmTokenUsecase.registerFcmToken(fcmToken, userId));
      } catch (e) {
        // Silently ignore for now
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final tokens = await _loginUseCase.execute(email, password);

      await LocalStorage.instance.setAccessToken(tokens!.accessToken);
      await LocalStorage.instance.setRefreshToken(tokens.refreshToken);

      await _ref.read(userNotifierProvider.notifier).fetchUser();
      unawaited(_restartAndConfigureService());
      state = AsyncValue.data(tokens);
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
