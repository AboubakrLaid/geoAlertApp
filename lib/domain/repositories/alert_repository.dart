import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/reply.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts();
  Future<void> replyToAlert({required Reply reply});
}
