import 'package:geoalert/domain/entities/alert.dart';

class PaginatedAlerts {
  final List<Alert> alerts;
  String? nextPageUrl;
  String? previousPageUrl;

  PaginatedAlerts({
    required this.alerts,
    this.nextPageUrl,
    this.previousPageUrl,
  });
}
