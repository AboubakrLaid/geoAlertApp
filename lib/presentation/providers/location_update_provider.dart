import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/data/repositories/location_update_settings_repository_impl.dart';
import 'package:geoalert/domain/usecases/fetch_location_update_frequency_usecase.dart';
import 'package:geoalert/domain/usecases/send_current_location_usecase.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final locationUpdateSettingsProvider = Provider<LocationUpdateSettingsRepositoryImpl>((ref) {
  return LocationUpdateSettingsRepositoryImpl(ref.read(apiClientProvider));
});

final fetchLocationUpdateFrequencyUseCase = Provider((ref) {
  return GetLocationUpdateSettingsUseCase(ref.read(locationUpdateSettingsProvider));
});

final sendCurrentLocationUseCase = Provider((ref) {
  return SendCurrentLocationUseCase(ref.read(locationUpdateSettingsProvider));
});

final locationUpdateNotifierProvider = StateNotifierProvider<LocationUpdateNotifier, AsyncValue<int?>>((ref) {
  return LocationUpdateNotifier(ref.read(fetchLocationUpdateFrequencyUseCase), ref.read(sendCurrentLocationUseCase));
});

class LocationUpdateNotifier extends StateNotifier<AsyncValue<int?>> {
  final GetLocationUpdateSettingsUseCase _getFrequencyUseCase;
  final SendCurrentLocationUseCase _sendLocationUseCase;

  LocationUpdateNotifier(this._getFrequencyUseCase, this._sendLocationUseCase) : super(const AsyncValue.data(null));

  Future<void> loadFrequency() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _getFrequencyUseCase.execute();
      state = AsyncValue.data(settings?.frequency);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> sendLocation({required int userId, required double latitude, required double longitude}) async {
    try {
      await _sendLocationUseCase.execute(userId: userId, latitude: latitude, longitude: longitude);
    } catch (e) {
      print("Failed to send location: $e");
    }
  }
}
