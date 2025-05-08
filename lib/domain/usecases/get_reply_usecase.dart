import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/reply_repository.dart';

class GetReplyUseCase {
  final ReplyRepository repository;

  GetReplyUseCase(this.repository);

  Future<Reply?> execute({required String alertId, required int userId, required int notificationId}) {
    return repository.getReplie(alertId: alertId, userId: userId, notificationId: notificationId);
  }
}
