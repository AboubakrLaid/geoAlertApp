import 'package:geoalert/domain/repositories/location_update_settings_repository.dart';

class SendCurrentLocationUseCase {
  final LocationUpdateSettingsRepository repository;

  SendCurrentLocationUseCase(this.repository);

  Future<void> execute({required int userId, required double latitude, required double longitude}) {
    return repository.updateCurrentPosition(userId: userId, latitude: latitude, longitude: longitude);
  }
}
