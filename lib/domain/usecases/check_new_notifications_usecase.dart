import 'package:geoalert/domain/repositories/alert_repository.dart';

class CheckNewNotificationsUsecase {
  final AlertRepository _repository;

  CheckNewNotificationsUsecase(this._repository);

  Future<bool> execute({required String lastCheckedDate}) {
    return _repository.checkForNewAlerts(lastCheckedDate: lastCheckedDate);
  }
}
