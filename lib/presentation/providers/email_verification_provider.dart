import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/data/repositories/email_verification_repository_impl.dart';
import 'package:geoalert/domain/repositories/email_verification_repository.dart';
import 'package:geoalert/domain/usecases/confirm_email_usecase.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart';

final emailVerificationRepositoryProvider = Provider<EmailVerificationRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EmailVerificationRepositoryImpl(apiClient);
});

final confirmEmailUseCaseProvider = Provider<ConfirmEmailUseCase>((ref) => ConfirmEmailUseCase(ref.read(emailVerificationRepositoryProvider)));

final emailVerificationProvider = StateNotifierProvider<EmailVerificationNotifier, AsyncValue<void>>((ref) => EmailVerificationNotifier(ref.read(confirmEmailUseCaseProvider)));

class EmailVerificationNotifier extends StateNotifier<AsyncValue<void>> {
  final ConfirmEmailUseCase _confirmEmailUseCase;

  EmailVerificationNotifier(this._confirmEmailUseCase) : super(const AsyncValue.data(null));

  Future<void> verifyEmail({required String email, required String code}) async {
    state = const AsyncValue.loading();
    try {
      await _confirmEmailUseCase.verifyEmail(email: email, code: code);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  Future<void> resendCode({required String email}) async {
    state = const AsyncValue.loading();
    try {
      await _confirmEmailUseCase.resendCode(email: email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }
}
