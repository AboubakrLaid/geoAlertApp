import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/presentation/providers/reply_provider.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/audio_player_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:geoalert/domain/entities/alert.dart';

class AlertDetailDialog extends ConsumerStatefulWidget {
  final Alert alert;

  const AlertDetailDialog({super.key, required this.alert});

  @override
  ConsumerState createState() => _AlertDetailDialogState();
}

class _AlertDetailDialogState extends ConsumerState<AlertDetailDialog> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await LocalStorage.instance.getUserId();
      if (userId == null) {
        // Handle the case where userId is not available
        return;
      }
      // Check if the reply is already cached
      if (ref.read(replyProvider.notifier).isReplyCached(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id)) {
        return; // Reply is already cached, no need to fetch again
      }
      // Fetch the reply if not cached
      ref.read(replyProvider.notifier).fetchReply(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final replyState = ref.watch(replyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Drag handle
          Center(child: Container(width: 50, height: 5, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),

          // Alert status
          Row(
            children: [
              Icon(widget.alert.beenRepliedTo ? Icons.check_circle : Icons.warning_amber_rounded, color: widget.alert.beenRepliedTo ? Colors.green : Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.alert.beenRepliedTo ? 'This alert has been acknowledged.' : 'This alert has not been acknowledged.',
                style: TextStyle(fontSize: 14, color: widget.alert.beenRepliedTo ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(widget.alert.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          // Metadata
          if (widget.alert.date != null)
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                // Text(Jiffy.parseFromDateTime(widget.alert.date!).format(pattern: 'MMM dd, yyyy'), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                // make the date like : 4 days ago
                Text(Jiffy.parseFromDateTime(widget.alert.date!).fromNow(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: [_buildTag(text: widget.alert.dangerType.toUpperCase()), _buildTag(text: widget.alert.severity.value.toUpperCase(), textColor: _getSeverityTextColor(widget.alert.severity))],
          ),

          const SizedBox(height: 24),

          // Description
          Row(
            children: [const Icon(Icons.description, color: Colors.black54), const SizedBox(width: 6), Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))],
          ),
          const SizedBox(height: 8),
          Text(widget.alert.body, style: const TextStyle(fontSize: 14, height: 1.5)),

          const SizedBox(height: 24),

          // Reply Section
          if (widget.alert.beenRepliedTo) ...[
            replyState.when(
              data:
                  (reply) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.message_outlined, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text("Your reply", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (reply != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reply.text != null)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 266),
                                  child: Scrollbar(thumbVisibility: true, child: SingleChildScrollView(child: Text(reply.text!, style: const TextStyle(fontSize: 14)))),
                                ),
                              if (reply.replyType == "audio") ...[const SizedBox(height: 8), AudioPlayerWidget(audioUrl: reply.audioUrl!)],
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, st) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to load your response'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final userId = await LocalStorage.instance.getUserId();
                          if (userId == null) {
                            // Handle the case where userId is not available
                            return;
                          }
                          ref.read(replyProvider.notifier).fetchReply(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
            ),
          ],
          // add space here
          // View on Map Button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text('View on Map', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(220, 9, 26, 1),
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                // to do
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
      return const Color(0xFF252525);
  }
}

Widget _buildTag({required String text, Color? textColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1))),
    child: Text(text, style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 12, fontWeight: FontWeight.w500, color: textColor ?? const Color(0xFF252525))),
  );
}
