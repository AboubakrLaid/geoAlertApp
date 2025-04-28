import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;

  GetAlertsUseCase(this.repository);

  Future<List<Alert>> execute() {
    return repository.getAlerts();
  }
}
