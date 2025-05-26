import 'package:flutter/material.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/alert_dialogue.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/expandable_text.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
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
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (alert.isExpired) _buildTag(text: 'EXPIRED', textColor: const Color(0xFFDC091A), icon: Icons.hourglass_bottom),
                _buildTag(text: alert.dangerType.toUpperCase()),
                _buildTag(text: alert.severity.value.toUpperCase(), textColor: _getSeverityTextColor(alert.severity)),
              ],
            ),

            const SizedBox(height: 8),

            if (alert.date != null)
              // format is MMM dd, yyyy at hh:mm
              Text(
                Jiffy.parseFromDateTime(alert.date!).format(pattern: 'MMM dd, yyyy At HH:mm'),
                style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFA9A9A9)),
              ),
            const SizedBox(height: 8),
            Text(alert.title, style: const TextStyle(fontFamily: "TittilumWeb", fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF252525)), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            // Text(alert.body, style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF252525)), maxLines: 3, overflow: TextOverflow.ellipsis),
            ExpandableText(text: alert.body),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!alert.beenRepliedTo && !alert.isExpired)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert.isExpired ? const Color(0xFFD9D9D9) : const Color.fromRGBO(220, 9, 26, 1),
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),

                    onPressed: () {
                      GoRouter.of(context).push(Routes.replyToAlert, extra: alert);
                    },
                    child: const Text('Acknowledge', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                  ),

                if (alert.beenRepliedTo)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                    onPressed: () {
                      GoRouter.of(context).push(Routes.viewReply, extra: alert);
                    },
                    child: const Text('View Reply', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Color.fromRGBO(37, 37, 37, 1))),
                  ),
                if (!alert.isExpired)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                    onPressed: () {
                      GoRouter.of(context).push(Routes.map, extra: alert);
                    },
                    child: const Text('View Map', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Color.fromRGBO(37, 37, 37, 1))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({required String text, Color? textColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: textColor ?? const Color(0xFF252525)), const SizedBox(width: 2)],
          Text(text, style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: FontWeight.w500, color: textColor ?? const Color(0xFF252525))),
        ],
      ),
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
