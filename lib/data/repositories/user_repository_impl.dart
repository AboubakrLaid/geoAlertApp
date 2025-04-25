import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/user_model.dart';
import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

  @override
  Future<User?> getUserProfile() async {
    try {
      final response = await _apiClient.get('/ms-auth/api/auth/me', requireAuth: true);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      handleApiException(e as ApiException);
    }
    return null;
  }
}
