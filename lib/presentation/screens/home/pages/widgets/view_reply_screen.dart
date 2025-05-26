import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/presentation/providers/reply_provider.dart';
import 'package:geoalert/presentation/screens/home/pages/widgets/audio_player_widget.dart';
import 'package:go_router/go_router.dart';

class ViewReplyScreen extends ConsumerStatefulWidget {
  final Alert alert;
  const ViewReplyScreen({super.key, required this.alert});

  @override
  ConsumerState<ViewReplyScreen> createState() => _ViewReplyScreenState();
}

class _ViewReplyScreenState extends ConsumerState<ViewReplyScreen> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await LocalStorage.instance.getUserId();
      if (userId == null) return;

      ref.read(replyProvider.notifier).fetchReply(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final replyState = ref.watch(replyProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Row(
              children: [
                IconButton(onPressed: () => GoRouter.of(context).pop(), icon: const Icon(Icons.arrow_back, color: Colors.black), padding: const EdgeInsets.all(16)),
                const SizedBox(width: 8),
                const Text("View reply", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, fontFamily: 'TittilumWeb')),
              ],
            ),
            const Divider(color: Color.fromRGBO(208, 213, 221, 1), thickness: 1, height: 40),
            Expanded(
              child: replyState.when(
                data:
                    (reply) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          Center(
                            child: Text(
                              "You cannot send another reply.\nYou can only view your reply here.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Space Grotesk', color: Color.fromRGBO(37, 37, 37, 1)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          reply != null
                              ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color.fromRGBO(208, 213, 221, 1))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (reply.replyType == "audio") ...[
                                      Row(
                                        children: [
                                          Image.asset('assets/images/voice-red.png', height: 30, width: 30),
                                          const SizedBox(width: 16),
                                          const Text("Vocal response", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'TittilumWeb')),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AudioPlayerWidget(audioUrl: reply.audioUrl!),
                                    ],
                                    if (reply.text!.isNotEmpty && reply.replyType == "audio") const Divider(color: Color.fromRGBO(208, 213, 221, 1), thickness: 1, height: 24),
                                    if (reply.text!.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Image.asset('assets/images/T-red.png', height: 30, width: 30),
                                          const SizedBox(width: 16),
                                          const Text("Text response", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'TittilumWeb')),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromRGBO(196, 196, 196, 0.2)),
                                        child: Text(reply.text!, style: const TextStyle(fontSize: 14)),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              )
                              : Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final userId = await LocalStorage.instance.getUserId();
                                    if (userId == null) return;

                                    ref.read(replyProvider.notifier).fetchReply(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id);
                                  },
                                  child: const Text('Failed to load reply, try again'),
                                ),
                              ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, st) => Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final userId = await LocalStorage.instance.getUserId();
                          if (userId == null) return;

                          ref.read(replyProvider.notifier).fetchReply(alertId: widget.alert.alertId, userId: userId, notificationId: widget.alert.id);
                        },
                        child: const Text('Failed to load reply, try again'),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
