import 'package:flutter/material.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/alert_dialogue.dart';
import 'package:geoalert/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:geoalert/domain/entities/alert.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  // final VoidCallback? onAcknowledge;

  const AlertCard({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: InkWell(
        onTap: () {
          // showDialog(context: context, builder: (context) => AlertDetailDialog(alert: alert));
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent, // Needed to create custom barrier and full height sheet
            builder: (context) {
              return Stack(
                children: [
                  // Dismiss barrier on top
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2, // Height of the dismissible area
                      color: Colors.transparent,
                    ),
                  ),
                  // Bottom Sheet content
                  DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    builder: (_, controller) {
                      return Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        child: SingleChildScrollView(controller: controller, child: AlertDetailDialog(alert: alert)),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // if (alert.beenRepliedTo) ...[Icon(Icons.check_circle, color: Color(0xFF22A447), size: 20), SizedBox(width: 8)],
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Text(
                        alert.title,
                        style: const TextStyle(fontFamily: "TittilumWeb", fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF252525)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (alert.date != null)
                  Text(
                    Jiffy.parseFromDateTime(alert.date!).format(pattern: 'MMM dd, yyyy'),
                    style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFA9A9A9)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [_buildTag(text: alert.dangerType.toUpperCase()), _buildTag(text: alert.severity.value.toUpperCase(), textColor: _getSeverityTextColor(alert.severity))],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical Divider
                Container(
                  width: 4,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), // rgba(217, 217, 217, 1)
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Alert Body Text
                Expanded(
                  child: Text(
                    alert.body,
                    style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF252525)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!alert.beenRepliedTo) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(220, 9, 26, 1),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  GoRouter.of(context).push(Routes.replyToAlert, extra: alert);
                },
                child: const Text('Acknowledge', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag({required String text, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1))),
      child: Text(text, style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: FontWeight.w500, color: textColor ?? const Color(0xFF252525))),
    );
  }

  Color _getSeverityTextColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.minor:
        return const Color(0xFF22A447);
      case AlertSeverity.moderate:
        return const Color(0xFFFBA23C);
      case AlertSeverity.severe:
        return const Color(0xFFDC091A);
      default:
        return const Color(0xFF252525); // Default color if severity is not recognized
    }
  }
}
