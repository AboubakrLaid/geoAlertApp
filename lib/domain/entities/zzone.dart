import 'package:geoalert/domain/entities/coordinate.dart';

class Zzone {
  final String id;
  final String name;
  final List<Coordinate> coordinates;
  final bool isActive;

  Zzone({required this.id, required this.name, required this.coordinates, required this.isActive});
}
