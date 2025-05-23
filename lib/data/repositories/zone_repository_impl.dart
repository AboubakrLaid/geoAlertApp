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
      // sidi bel abbes
      // return Zzone(
      //   id: _uuid.v4(),
      //   name: 'Sidi Bel Abbes',
      //   coordinates: [
      //     Coordinate(latitude: 35.210, longitude: -0.650), // Northwest
      //     Coordinate(latitude: 35.210, longitude: -0.610), // Northeast
      //     Coordinate(latitude: 35.170, longitude: -0.610), // Southeast
      //     Coordinate(latitude: 35.170, longitude: -0.650), // Southwest
      //     Coordinate(latitude: 35.210, longitude: -0.650), // Close the polygon
      //   ],
      // );
      // return Zzone(
      //   id: 'algiers_rectangle_zone', // Replace with your UUID generator
      //   name: 'Algiers Security Zone',
      //   coordinates: [
      //     Coordinate(latitude: 36.872557, longitude: 2.896593), // Northwest
      //     Coordinate(latitude: 36.576281, longitude: 2.896593), // Southwest
      //     Coordinate(latitude: 36.576281, longitude: 3.290619), // Southeast
      //     Coordinate(latitude: 36.872557, longitude: 3.290619), // Northeast
      //     Coordinate(latitude: 36.872557, longitude: 2.896593), // Close polygon
      //   ],
      // );
      // return Zzone(
      //   id: _uuid.v4(),
      //   name: 'Sidi Bel Abbes',
      //   coordinates: [
      //     Coordinate(latitude: 35.223645, longitude: -0.651175), // Northwest
      //     Coordinate(latitude: 35.215049, longitude: -0.661418),
      //     Coordinate(latitude: 35.208012, longitude: -0.667761),
      //     Coordinate(latitude: 35.176817, longitude: -0.674149), // Southernmost
      //     Coordinate(latitude: 35.171840, longitude: -0.639826),
      //     Coordinate(latitude: 35.174105, longitude: -0.611579),
      //     Coordinate(latitude: 35.179989, longitude: -0.595798), // Northeast
      //     Coordinate(latitude: 35.193782, longitude: -0.581974),
      //     Coordinate(latitude: 35.227439, longitude: -0.591722), // Northern tip
      //     Coordinate(latitude: 35.223645, longitude: -0.651175), // Close polygon
      //   ],
      // );

      final res = await _apiClient.get("/ms-alert/api/zone/$idAlert", requireAuth: true);
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
      final res = await _apiClient.get("/ms-alert/api/zone", requireAuth: true);
      final json = res.data;
      print(json);
      if (json != null) {
        print(json);
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
