import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/reply_model.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/reply_repository.dart';

class ReplyRepositoryImpl implements ReplyRepository {
  final ApiClient _apiClient;

  ReplyRepositoryImpl(this._apiClient);
  @override
  Future<Reply?> getReplie({required String alertId, required int userId, required int notificationId}) async {
    try {
      final url = "/ms-notification/api/notification-reply/?alert_id=$alertId&user_id=$userId&notification_id=$notificationId";
      final response = await _apiClient.get(url, requireAuth: true);
      final data = response.data;
      print("Response data: $data");
      return ReplyModel.fromJson(data["data"]);
    } catch (e) {
      handleApiException(e);
    }
    return null;
  }
}
