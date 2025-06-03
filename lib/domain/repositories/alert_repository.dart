import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/paginated_alerts.dart';
import 'package:geoalert/domain/entities/reply.dart';

abstract class AlertRepository {
  Future<PaginatedAlerts?> getAlerts({String? nextPageUrl, String? afterDate});
  // Future<List<Alert>> getNewsAlerts({required String afterDate});
  Future<void> replyToAlert({required Reply reply});
  // check if there are new alerts
  Future<bool> checkForNewAlerts({required String lastCheckedDate});
}
