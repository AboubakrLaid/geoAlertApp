import 'package:geoalert/domain/entities/zzone.dart';

abstract class ZoneRepository {
  Future<List<Zzone>> getZones();
  Future<Zzone?> getZone({required String idAlert});
}
