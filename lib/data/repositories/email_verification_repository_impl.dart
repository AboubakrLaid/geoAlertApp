import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/network_checker.dart';
import 'package:geoalert/domain/repositories/email_verification_repository.dart';

class EmailVerificationRepositoryImpl implements EmailVerificationRepository {
  final ApiClient _apiClient;
  final NetworkChecker _networkChecker;

  EmailVerificationRepositoryImpl(this._apiClient, this._networkChecker);

  @override
  Future<void> verifyEmail({required String email, required String code}) async {
    

    try {
      final response = await _apiClient.post('/ms-auth/api/auth/verify-email', {
        "email": email,
        "code": code,
      });
      print(response.data);
      if (response.statusCode != 200) {
        throw response.data["message"];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationCode({required String email}) async {
  
    try {
      final response = await _apiClient.post('/ms-auth/api/auth/resend-code', {
        "email": email,
      });

      if (response.statusCode != 200) {
        throw response.data["message"];
      }
    } catch (e) {
      rethrow;
    }
  }
}
