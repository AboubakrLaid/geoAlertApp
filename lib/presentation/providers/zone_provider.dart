import 'package:geoalert/data/repositories/zone_repository_impl.dart';
import 'package:geoalert/domain/entities/zzone.dart';
import 'package:geoalert/domain/repositories/zone_repository.dart';
import 'package:geoalert/domain/usecases/get_zones_usecase.dart';
import 'package:geoalert/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ZoneRepositoryImpl(apiClient);
});

final getZoneUseCaseProvider = Provider<GetZoneUseCase>((ref) {
  final repository = ref.read(zoneRepositoryProvider);
  return GetZoneUseCase(repository);
});

// zone provider
final zoneProvider = StateNotifierProvider<ZoneNotifier, AsyncValue<Zzone?>>((ref) => ZoneNotifier(ref.read(getZoneUseCaseProvider)));
// zones provider
final zonesProvider = StateNotifierProvider<ZonesNotifier, AsyncValue<List<Zzone>>>((ref) => ZonesNotifier(ref.read(getZoneUseCaseProvider)));

class ZoneNotifier extends StateNotifier<AsyncValue<Zzone?>> {
  final GetZoneUseCase _getZoneUseCase;

  ZoneNotifier(this._getZoneUseCase) : super(const AsyncValue.data(null));

  bool hasFetched = false;

  Future<void> fetchZone({required String idAlert}) async {
    state = const AsyncValue.loading();
    try {
      final zone = await _getZoneUseCase.getZone(idAlert: idAlert);
      state = AsyncValue.data(zone);
      hasFetched = true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      hasFetched = false;
    }
  }
}

class ZonesNotifier extends StateNotifier<AsyncValue<List<Zzone>>> {
  final GetZoneUseCase _getZoneUseCase;

  ZonesNotifier(this._getZoneUseCase) : super(const AsyncValue.data([]));

  bool hasFetched = false;

  Future<void> fetchZones() async {
    state = const AsyncValue.loading();
    try {
      final zones = await _getZoneUseCase.getZones();
      state = AsyncValue.data(zones);
      hasFetched = true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      hasFetched = false;
    }
  }
}
