

abstract class EmailVerificationRepository {
  Future<void> verifyEmail({required String email, required String code});
  Future<void> resendVerificationCode({required String email});
  
}
