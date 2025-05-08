import 'package:geoalert/domain/entities/reply.dart';

abstract class ReplyRepository {
  Future<Reply?> getReplie({required String alertId, required int userId, required int notificationId});
}
