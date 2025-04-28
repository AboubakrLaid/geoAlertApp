import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/network/exception_handler.dart';
import 'package:geoalert/data/models/alert_model.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:geoalert/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final ApiClient _apiClient;

  AlertRepositoryImpl(this._apiClient);

  // @override
  // Future<List<Alert>> getAlerts() async {
  //   try {
  //     final response = await _apiClient.get('/alerts', requireAuth: true);
  //     final List<dynamic> data = response.data['data'];

  //     return data.map((json) => AlertModel.fromJson({'data': json})).toList();
  //   } catch (e) {
  //     handleApiException(e);
  //     return []; // fallback
  //   }
  // }
  @override
  Future<List<Alert>> getAlerts() async {
    try {
      // Simulate a network delay
      await Future.delayed(const Duration(seconds: 2));

      // Create 15 fake alerts
      List<Alert> fakeAlerts = List.generate(15, (index) {
        return Alert(
          alertId: index + 1,
          userId: 123, // Dummy userId
          title: 'Alerthsfdsh #${index + 1}',
          body:
              'This is a fake alert message sdhfsdfhsdlkkkkk\\kkkkkkkkkkkkkkkkkkkkkkkkkkkk\\kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhkllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllldsddddddkbody for alert number ${index + 1}.',
          beenRepliedTo: (index % 2 == 0) ? true : false, // Alternate between replied and not replied
          severity: AlertSeverity.values[index % 3], // Cycle through severity levels
          dangerType: 'General', // A general type for this fake example
          date: DateTime.now().subtract(Duration(days: index)), // Different dates for each alert
        );
      });

      return fakeAlerts;
    } catch (e) {
      handleApiException(e);
      return []; // fallback
    }
  }

  @override
  Future<void> replyToAlert({required Reply reply}) async {
    print("reply ${reply.text}");
    print(reply.audio);
  }
}
