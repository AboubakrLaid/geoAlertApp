import 'package:geoalert/data/models/alert_model.dart';
import 'package:geoalert/domain/entities/paginated_alerts.dart';

class PaginatedAlertsModel extends PaginatedAlerts {
  PaginatedAlertsModel({
    required super.alerts,
    super.nextPageUrl,
    super.previousPageUrl,
  });

  factory PaginatedAlertsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedAlertsModel(
      alerts: (json['results'] as List).map((alertJson) => AlertModel.fromJson(alertJson)).toList(),
      nextPageUrl: json['next'],
      previousPageUrl: json['previous'],
    );
  }
}
