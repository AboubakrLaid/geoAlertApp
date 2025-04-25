import 'package:geoalert/domain/entities/location_update_settings.dart';
import 'package:geoalert/domain/repositories/location_update_settings_repository.dart';

class GetLocationUpdateSettingsUseCase {
  final LocationUpdateSettingsRepository locationUpdateSettingsRepository;

  GetLocationUpdateSettingsUseCase(this.locationUpdateSettingsRepository);

  Future<LocationUpdateSettings?> execute() async {
    return await locationUpdateSettingsRepository.getLocationUpdateSettings();
  }
}
