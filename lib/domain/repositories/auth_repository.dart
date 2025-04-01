import 'package:geoalert/domain/entities/auth_tokens.dart';
import 'package:geoalert/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AuthTokens?> login(String email, String password);
  Future<User?> register(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String password,
  );
  
}
