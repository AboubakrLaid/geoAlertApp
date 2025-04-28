import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class ReplyToAlertUseCase {
  final AlertRepository repository;

  ReplyToAlertUseCase(this.repository);

  Future<void> execute({required Reply reply}) {
    return repository.replyToAlert(reply: reply);
  }
}
