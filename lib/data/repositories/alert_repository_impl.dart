import 'package:dio/dio.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/alert_model.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final ApiClient _apiClient;

  AlertRepositoryImpl(this._apiClient);

  @override
  Future<List<Alert>> getAlerts() async {
    try {
      final response = await _apiClient.get('/ms-notification/api/notification/');
      List<Alert> alerts = [];
      for (var json in response.data) {
        alerts.add(AlertModel.fromJson(json));
      }
      if (alerts.isNotEmpty) {
        alerts.sort((a, b) => b.date!.compareTo(a.date!));
      }
      return alerts;
    } catch (e) {
      handleApiException(e);
      return []; // fallback
    }
  }

  @override
  Future<void> replyToAlert({required Reply reply}) async {
    print("reply ${reply.text}");
    print(reply.audioFilePath);

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
      print('Reply sent: ${response.data}');
      // Here you would typically send the reply to the server
      // For this example, we'll just print it
      print('Reply sent: ${reply.text}');
    } catch (e) {
      handleApiException(e);
    }
  }

  @override
  Future<bool> checkForNewAlerts({required String lastCheckedDate}) async {
    try {
      final url = '/ms-notification/api/check-new-notifications/?last_checked=$lastCheckedDate';
      final response = await _apiClient.get(url, requireAuth: true);
      return response.data['has_new_notifications'] ?? false;
    } catch (e) {
      handleApiException(e);
      return false;
    }
  }
}
