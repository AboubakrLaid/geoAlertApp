import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/repositories/user_repository_impl.dart';
import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/usecases/get_user_profile_usecase.dart';

// ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Repository provider
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl(ref.read(apiClientProvider));
});

// UseCase provider
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.read(userRepositoryProvider));
});

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref.read(getUserProfileUseCaseProvider));
});

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final GetUserProfileUseCase _useCase;

  UserNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _useCase.call();
      state = AsyncValue.data(user);

      if (user != null) {
        await LocalStorage.instance.setUserId(user.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}
