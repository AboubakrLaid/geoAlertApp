import 'package:geoalert/domain/entities/zzone.dart';
import 'package:geoalert/domain/repositories/zone_repository.dart';

class GetZoneUseCase {
  final ZoneRepository _repository;

  GetZoneUseCase(this._repository);

  Future<Zzone?> getZone({required String idAlert}) {
    return _repository.getZone(idAlert: idAlert);
  }

  Future<List<Zzone>> getZones() {
    return _repository.getZones();
  }
}
