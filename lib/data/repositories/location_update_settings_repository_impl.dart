import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/domain/entities/location_update_settings.dart';
import 'package:geoalert/domain/repositories/location_update_settings_repository.dart';

class LocationUpdateSettingsRepositoryImpl implements LocationUpdateSettingsRepository {
  final ApiClient _apiClient;

  LocationUpdateSettingsRepositoryImpl(this._apiClient);

  @override
  Future<LocationUpdateSettings?> getLocationUpdateSettings() async {
    try {
      final response = await _apiClient.get('/ms-GeoLocation/api/getfrequency', requireAuth: true);
      if (response.statusCode == 200) {
        final frequency = int.parse(response.data);
        return LocationUpdateSettings(frequency: frequency);
      }
    } catch (e) {
      e as ApiException;
      handleApiException(e);
    }
    return null;
  }

  @override
  Future<void> updateCurrentPosition({required int userId, required double latitude, required double longitude}) async {
    try {
      final data = {
        'UserId': userId,
        "position": [
          {'latitude': latitude, 'longitude': longitude},
        ],
      };
      print("data : $data");
      final result = await _apiClient.post('/ms-GeoLocation/api/updateCurrentPosition', data, requireAuth: true);
      if (result.statusCode == 200) {
        return;
      }
    } catch (e) {
      e as ApiException;
      handleApiException(e);
    }
  }
}
