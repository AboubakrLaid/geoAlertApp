class Alert {
  final int alertId;
  final int userId;
  final String title;
  final String body;
  final bool beenRepliedTo;
  final AlertSeverity severity;
  final String dangerType;
  final DateTime? date;

  Alert({required this.date, required this.alertId, required this.userId, required this.title, required this.body, required this.beenRepliedTo, required this.severity, required this.dangerType});
}

enum AlertSeverity { minor, moderate, severe }

extension AlertSeverityExtension on AlertSeverity {
  String get value {
    switch (this) {
      case AlertSeverity.minor:
        return "Minor";
      case AlertSeverity.moderate:
        return "Moderate";
      case AlertSeverity.severe:
        return "Severe";
    }
  }

  static AlertSeverity fromString(String severity) {
    switch (severity) {
      case "Minor":
        return AlertSeverity.minor;
      case "Moderate":
        return AlertSeverity.moderate;
      case "Severe":
        return AlertSeverity.severe;
      default:
        throw Exception('Unknown severity: $severity');
    }
  }
}
