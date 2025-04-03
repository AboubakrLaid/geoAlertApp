import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/domain/repositories/test_repository.dart';

class TestRepositoryImpl implements TestRepository {
  final ApiClient _apiClient;

  TestRepositoryImpl(this._apiClient);

  @override
  Future<void> callProtected() async {
    // Simulate a network call
    try {
      final response = await _apiClient.get('/ms-auth/api/auth/protected', requireAuth: true);
      print(response.statusCode);
      print(response.data);
    } catch (e) {
      handleApiException(e);
    }
  }
}
