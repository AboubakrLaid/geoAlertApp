import 'package:geoalert/domain/entities/location_update_settings.dart';

abstract class LocationUpdateSettingsRepository {
  Future<LocationUpdateSettings?> getLocationUpdateSettings();

  Future<void> updateCurrentPosition({required int userId, required double latitude, required double longitude});
}
