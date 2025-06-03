import 'package:geoalert/domain/entities/paginated_alerts.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;

  GetAlertsUseCase(this.repository);

  Future<PaginatedAlerts?> execute({String? nextPageUrl, String? afterDate}) {
    return repository.getAlerts(nextPageUrl: nextPageUrl, afterDate: afterDate);
  }
}
