import 'package:geoalert/data/repositories/firebase_repository_impl.dart';

class RegisterFcmTokenUsecase {
  final FireBaseRepositoryImpl _fcmTokenRepository;

  RegisterFcmTokenUsecase(this._fcmTokenRepository);

  Future<void> registerFcmToken(String token, int userId) async {
    await _fcmTokenRepository.registerFcmToken(token, userId);
  }
}
