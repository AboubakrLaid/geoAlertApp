import 'package:dio/dio.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/models/alert_model.dart';
import 'package:geoalert/data/models/paginated_alerts_model.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/paginated_alerts.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final ApiClient _apiClient;

  AlertRepositoryImpl(this._apiClient);

  @override
  Future<PaginatedAlerts?> getAlerts({String? nextPageUrl, String? afterDate}) async {
    try {
      final userId = await LocalStorage.instance.getUserId();
      final String url = nextPageUrl ?? (afterDate != null ? '/ms-notification/api/notification/$userId/?$afterDate' : '/ms-notification/api/notification/$userId/');
      final response = await _apiClient.get(url, requireAuth: true);
      return PaginatedAlertsModel.fromJson(response.data);
    } catch (e) {
      handleApiException(e);
    }
    return null;
  }

  @override
  Future<void> replyToAlert({required Reply reply}) async {
    try {
      // /ms-notification/api/reply
      FormData formData = FormData.fromMap({
        'alert_id': reply.alertId,
        'text': reply.text,
        'audio': reply.audioFilePath != null ? await MultipartFile.fromFile(reply.audioFilePath!) : null,
        'user_id': reply.userId,
        "reply_type": reply.replyType,
        "notification_id": reply.notificationId,
      });
      // Simulate a network delay
      final response = await _apiClient.post('/ms-notification/api/reply/', formData);
    } catch (e) {
      handleApiException(e);
    }
  }

  @override
  Future<bool> checkForNewAlerts({required String lastCheckedDate}) async {
    try {
      final userId = await LocalStorage.instance.getUserId();
      final url = '/ms-notification/api/check-new-notifications/$userId/?last_checked=$lastCheckedDate';
      final response = await _apiClient.get(url, requireAuth: true);
      return response.data['has_new_notifications'] ?? false;
    } catch (e) {
      handleApiException(e);
      return false;
    }
  }
}
