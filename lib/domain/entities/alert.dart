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
  final bool isExpired;
  final bool isDisabled;

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
    required this.isExpired,
    required this.isDisabled,
  });

  Alert copyWith({
    int? id,
    String? alertId,
    int? userId,
    int? notificationId,
    String? title,
    String? body,
    bool? beenRepliedTo,
    AlertSeverity? severity,
    String? dangerType,
    DateTime? date,
    bool? isExpired,
    bool? isDisabled,
  }) {
    return Alert(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      userId: userId ?? this.userId,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      beenRepliedTo: beenRepliedTo ?? this.beenRepliedTo,
      severity: severity ?? this.severity,
      dangerType: dangerType ?? this.dangerType,
      date: date ?? this.date,
      isExpired: isExpired ?? this.isExpired,
      isDisabled: isDisabled ?? this.isDisabled,
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
