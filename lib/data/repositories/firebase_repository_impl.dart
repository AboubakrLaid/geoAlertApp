import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/domain/repositories/firebase_repository.dart';

class FireBaseRepositoryImpl implements FirebaseRepository {
  final ApiClient _apiClient;
  FireBaseRepositoryImpl(this._apiClient);

  @override
  Future<void> registerFcmToken(String token, int userId) async {
    try {
      // Simulate a network delay
      await _apiClient.post('/ms-notification/api/devices/', {'token': token, 'user_id': userId});
    } catch (e) {
      // Handle exceptions if needed
      handleApiException(e);
    }
  }
}
