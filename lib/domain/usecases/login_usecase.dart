import 'package:geoalert/domain/entities/auth_tokens.dart';
import 'package:geoalert/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthTokens?> execute(String email, String password) {
    return repository.login(email, password);
  }
}
