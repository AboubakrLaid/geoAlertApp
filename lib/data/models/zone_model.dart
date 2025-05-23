import 'package:geoalert/data/models/coordinate_model.dart';
import 'package:geoalert/domain/entities/zzone.dart';
import 'package:uuid/uuid.dart';

class ZoneModel extends Zzone {
  ZoneModel({required super.id, required super.name, required super.coordinates, required super.isActive});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: const Uuid().v4(),
      name: json['name'],
      coordinates: (json['coordinates'] as List).map((coord) => CoordinateModel.fromJson(coord)).toList(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'coordinates': coordinates.map((coord) => CoordinateModel(latitude: coord.latitude, longitude: coord.longitude).toJson()).toList()};
  }
}
