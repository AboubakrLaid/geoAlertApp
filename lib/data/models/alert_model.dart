import 'package:geoalert/domain/entities/alert.dart';

class AlertModel extends Alert {
  AlertModel({
    required super.id,
    required super.alertId,
    required super.notificationId,
    required super.date,
    required super.userId,
    required super.title,
    required super.body,
    required super.beenRepliedTo,
    required super.severity,
    required super.dangerType,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      alertId: json['alert_id'],
      userId: json['user_id'],
      notificationId: json['id'],
      title: json['title'],
      body: json['body'],
      beenRepliedTo: json['been_replied_to'],
      severity: AlertSeverity(json['severity']),
      dangerType: json['danger_type'],
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'alertId': alertId, 'userId': userId, 'title': title, 'body': body, 'beenRepliedTo': beenRepliedTo, 'severity': severity.value, 'dangerType': dangerType};
  }
}
