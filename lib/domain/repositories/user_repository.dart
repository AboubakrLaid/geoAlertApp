import 'package:geoalert/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserProfile();
}
