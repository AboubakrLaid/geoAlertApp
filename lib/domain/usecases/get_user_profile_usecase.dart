import 'package:geoalert/domain/entities/user.dart';
import 'package:geoalert/domain/repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getUserProfile();
  }
}
