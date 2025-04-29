import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:geoalert/domain/entities/alert.dart';

class AlertDetailDialog extends StatelessWidget {
  final Alert alert;

  const AlertDetailDialog({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              alert.beenRepliedTo
                  ? Text('This alert has been acknowledged.', style: const TextStyle(fontSize: 14, color: Colors.green))
                  : Text('This alert has not been acknowledged.', style: const TextStyle(fontSize: 14, color: Colors.red)),
              const SizedBox(height: 10),
              Text(alert.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (alert.date != null) Text('Date: ${Jiffy.parseFromDateTime(alert.date!).format(pattern: 'MMM dd, yyyy')}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 10),
              Text('Danger Type: ${alert.dangerType}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Text('Severity: ${alert.severity.value}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              Text('Description:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(alert.body, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
