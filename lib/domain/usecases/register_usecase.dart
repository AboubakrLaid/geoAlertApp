import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> execute({required String firstName, required String lastName, required String email, required String phoneNumber, required String password}) {
    return repository.register(firstName, lastName, email, phoneNumber, password);
  }
}
