import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/zone_model.dart';
import 'package:geoalert/domain/entities/coordinate.dart';
import 'package:geoalert/domain/entities/zzone.dart';
import 'package:geoalert/domain/repositories/zone_repository.dart';
import 'package:uuid/uuid.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ApiClient _apiClient;

  final _uuid = const Uuid();

  ZoneRepositoryImpl(this._apiClient);
  @override
  Future<Zzone?> getZone({required String idAlert}) async {
    try {
      // Simulate a network delay
      // await Future.delayed(const Duration(seconds: 2));
      // return Future.value(
      //   Zzone(
      //     id: _uuid.v4(),
      //     name: 'Zone A',
      //     coordinates: [
      //       Coordinate(latitude: 36.75, longitude: 3.06), // Algiers
      //       Coordinate(latitude: 35.6971, longitude: -0.6308), // Oran
      //       Coordinate(latitude: 36.365, longitude: 6.6147), // Constantine
      //       Coordinate(latitude: 31.61, longitude: -2.23), // Béchar
      //       Coordinate(latitude: 35.38, longitude: 1.32), // Tiaret
      //     ],
      //   ),
      // );
      final res = await _apiClient.get("/ms-alert/api/zone/A2", requireAuth: true);
      final json = res.data;
      if (json != null) {
        return ZoneModel.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      handleApiException(e);
    }
    return null;
  }

  @override
  Future<List<Zzone>> getZones() async {
    try {
      // zone of Mostaganem, Oran, Tiaret, and Algiers
      // Simulate a network delay
      // await Future.delayed(const Duration(seconds: 2));
      // return Future.value([
      //   Zzone(
      //     id: _uuid.v4(),
      //     name: 'Mostaganem',
      //     coordinates: [
      //       Coordinate(latitude: 35.968, longitude: 0.089), // Northwest coast
      //       Coordinate(latitude: 36.030, longitude: 0.295), // North-central
      //       Coordinate(latitude: 35.954, longitude: 0.425), // Northeast edge
      //       Coordinate(latitude: 35.775, longitude: 0.349), // East inland
      //       Coordinate(latitude: 35.677, longitude: 0.134), // Southeast
      //       Coordinate(latitude: 35.791, longitude: -0.001), // Southwest
      //       Coordinate(latitude: 35.900, longitude: -0.050), // West inland
      //     ],
      //   ),
      //   Zzone(
      //     id: _uuid.v4(),
      //     name: 'Oran',
      //     coordinates: [
      //       Coordinate(latitude: 35.6971, longitude: -0.6308), // Oran
      //       Coordinate(latitude: 35.688, longitude: -0.600), // North
      //       Coordinate(latitude: 35.700, longitude: -0.650), // South
      //       Coordinate(latitude: 35.680, longitude: -0.700), // East
      //       Coordinate(latitude: 35.710, longitude: -0.600), // West
      //     ],
      //   ),
      //   Zzone(
      //     id: _uuid.v4(),
      //     name: 'Tiaret',
      //     coordinates: [
      //       Coordinate(latitude: 35.38, longitude: 1.32), // Tiaret
      //       Coordinate(latitude: 35.400, longitude: 1.300), // North
      //       Coordinate(latitude: 35.380, longitude: 1.350), // South
      //       Coordinate(latitude: 35.370, longitude: 1.320), // East
      //       Coordinate(latitude: 35.390, longitude: 1.310), // West
      //     ],
      //   ),
      //   Zzone(
      //     id: _uuid.v4(),
      //     name: 'Algiers',
      //     coordinates: [
      //       Coordinate(latitude: 36.75, longitude: 3.06), // Algiers
      //       Coordinate(latitude: 36.760, longitude: 3.070), // North
      //       Coordinate(latitude: 36.740, longitude: 3.060), // South
      //       Coordinate(latitude: 36.750, longitude: 3.080), // East
      //       Coordinate(latitude: 36.750, longitude: 3.050), // West
      //     ],
      //   ),
      // ]);
      final res = await _apiClient.get("/ms-alert/api/zone", requireAuth: true);
      final json = res.data;
      print(json);
      if (json != null) {
        return (json as List).map((zone) => ZoneModel.fromJson(zone)).toList();
      } else {
        return [];
      }
    } catch (e) {
      handleApiException(e);
    }
    return [];
  }
}
