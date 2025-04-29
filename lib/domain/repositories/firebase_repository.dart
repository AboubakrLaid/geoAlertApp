abstract class FirebaseRepository {
  Future<void> registerFcmToken(String token, int userId);
}
