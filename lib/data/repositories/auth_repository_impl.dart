import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/auth_tokens_model.dart';
import 'package:geoalert/data/models/user_model.dart';
import 'package:geoalert/domain/entities/auth_tokens.dart';
import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthTokens?> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/ms-auth/api/auth/login', {"email": email, "password": password});
      if (response.statusCode == 200) {
        return AuthTokensModel.fromJson(response.data);
      }
    } catch (e) {
      e as ApiException;
      print("From login ${e.message}");
      handleApiException(e);
    }
    return null;
  }

  @override
  Future<User?> register(String firstName, String lastName, String email, String phoneNumber, String password) async {
    try {
      final response = await _apiClient.post('/ms-auth/api/auth/register', {"firstName": firstName, "lastName": lastName, "email": email, "phoneNumber": phoneNumber, "password": password});

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      handleApiException(e);
    }
    return null;
  }
}
