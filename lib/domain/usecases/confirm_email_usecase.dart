import 'package:geoalert/domain/repositories/email_verification_repository.dart';

class ConfirmEmailUseCase {
  final EmailVerificationRepository _repository;

  ConfirmEmailUseCase(this._repository);

  Future<void> verifyEmail({required String email, required String code}) {
    return _repository.verifyEmail(email: email, code: code);
  }

  Future<void> resendCode({required String email}) {
    return _repository.resendVerificationCode(email: email);
  }
}
