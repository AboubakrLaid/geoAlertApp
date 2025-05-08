class Alert {
  final int id;
  final String alertId;
  final int userId;
  final int notificationId;
  final String title;
  final String body;
  final bool beenRepliedTo;
  final AlertSeverity severity;
  final String dangerType;
  final DateTime? date;

  Alert({
    required this.id,
    required this.notificationId,
    required this.date,
    required this.alertId,
    required this.userId,
    required this.title,
    required this.body,
    required this.beenRepliedTo,
    required this.severity,
    required this.dangerType,
  });

  Alert copyWith({required bool beenRepliedTo}) {
    return Alert(
      notificationId: notificationId,
      alertId: alertId,
      userId: userId,
      title: title,
      body: body,
      beenRepliedTo: beenRepliedTo,
      severity: severity,
      dangerType: dangerType,
      date: date,
      id: id,
    );
  }
}

class AlertSeverity {
  final String value;

  const AlertSeverity._(this.value);

  static const minor = AlertSeverity._("minor");
  static const moderate = AlertSeverity._("moderate");
  static const severe = AlertSeverity._("severe");

  // Allow creating new severities
  factory AlertSeverity(String value) {
    switch (value) {
      case "minor":
        return minor;
      case "moderate":
        return moderate;
      case "severe":
        return severe;
      default:
        return AlertSeverity._(value);
    }
  }

  @override
  String toString() => value;
}
