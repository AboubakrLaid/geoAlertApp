import 'package:geoalert/domain/entities/coordinate.dart';

class CoordinateModel extends Coordinate {
  CoordinateModel({required super.latitude, required super.longitude});

  factory CoordinateModel.fromJson(Map<String, dynamic> json) {
    return CoordinateModel(latitude: json['latitude'], longitude: json['longitude']);
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
