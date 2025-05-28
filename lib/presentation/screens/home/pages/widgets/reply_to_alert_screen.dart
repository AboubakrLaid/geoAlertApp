import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geoalert/domain/entities/reply.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_recorder/waveform_recorder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoalert/domain/entities/alert.dart';
import 'package:geoalert/presentation/providers/alert_provider.dart';
import 'package:geoalert/presentation/widgets/custom_elevated_button.dart';
import 'package:geoalert/presentation/widgets/custom_snack_bar.dart';
import 'package:flutter/foundation.dart';

class ReplyToAlertScreen extends ConsumerStatefulWidget {
  final Alert alert;
  const ReplyToAlertScreen({super.key, required this.alert});

  @override
  ConsumerState<ReplyToAlertScreen> createState() => _ReplyToAlertScreenState();
}

class _ReplyToAlertScreenState extends ConsumerState<ReplyToAlertScreen> {
  // used to play the audio
  bool _isPlaying = false;
  final int _timeLeft = 0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool _isEditingText = false;
  bool _isRecording = false;
  bool _isRecordingFinished = false;
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _waveController = WaveformRecorderController();
  Timer? _timer;
  int _seconds = 0;
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayer instance for playback

  @override
  void dispose() {
    _messageController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose(); // Dispose the audio player
    _timer?.cancel();
    ref.read(replyToAlertProvider.notifier).resetState(); // Reset the reply state
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      if (_waveController.isRecording) {
        await _waveController.stopRecording();
        _timer?.cancel();
      } else {
        try {
          await _waveController.startRecording();
        } catch (e) {
          CustomSnackBar.show(context, message: "Something went wrong while starting the recording. Please try again.", backgroundColor: const Color.fromRGBO(220, 9, 26, 1));
          return;
        }
        // await Future.delayed(Duration(milliseconds: 200));
        setState(() {
          _isRecording = true;
          _isRecordingFinished = false;
        });
        _startTimer();
      }
    } else {
      CustomSnackBar.show(context, message: "Permission to record audio is denied.");
    }
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds >= 30) {
        _stopRecording(); // Stop recording after 30 seconds
        timer.cancel();
      } else {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_waveController.isRecording) {
      await _waveController.stopRecording();
      setState(() {
        _isRecording = false;
        _isRecordingFinished = true;
        _totalDuration = Duration(seconds: _seconds);
      });
      _timer?.cancel();
      final file = _waveController.file;
    }
  }

  Future<void> _cancelRecording() async {
    if (_waveController.isRecording) {
      await _waveController.stopRecording();
      setState(() {
        _isRecording = false;
        _isRecordingFinished = false;
      });
      _timer?.cancel();
    }
  }

  Future<void> _playRecording() async {
    setState(() {
      _isPlaying = true;
    });
    final file = _waveController.file;
    if (file == null) return;
    final source = kIsWeb ? UrlSource(file.path) : DeviceFileSource(file.path);
    await _audioPlayer.play(source);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      // update the time left
      if (state == PlayerState.stopped || state == PlayerState.paused) {
        setState(() {
          _isPlaying = false;
        });
      } else if (state == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<void> _stopPlayback() async {
    setState(() {
      _isPlaying = false;
    });
    await _audioPlayer.stop();
  }

  Future<void> _deleteRecording() async {
    final file = _waveController.file;
    if (file != null) {
      final fileToDelete = File(file.path);
      await fileToDelete.delete(); // Delete the file

      setState(() {
        _isRecordingFinished = false; // Reset the state
      });
    }
  }

  Future<void> _submitReply() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final String alertId = widget.alert.alertId;
      final int userId = widget.alert.userId;
      final String? audioFilePath = _waveController.file?.path;
      final String text = _messageController.text.trim();
      final int notificationId = widget.alert.notificationId;
      final String replyType = audioFilePath != null ? "audio" : "text";
      final Reply reply = Reply(notificationId: notificationId, alertId: alertId, userId: userId, text: text, audioFilePath: audioFilePath, replyType: replyType);
      await ref.read(replyToAlertProvider.notifier).reply(reply: reply).whenComplete(() {
        if (mounted) {
          final replyState = ref.read(replyToAlertProvider);
          if (replyState.hasError) {
            CustomSnackBar.show(context, message: replyState.error.toString(), backgroundColor: const Color.fromRGBO(220, 9, 26, 1));
            if (replyState.error.toString().toLowerCase().contains("notification is expired")) {
              final alertIsExpired = widget.alert.copyWith(isExpired: true);
              ref.read(alertProvider.notifier).updateAlert(alertIsExpired);
            } else if (replyState.error.toString().toLowerCase().contains("notification is disabled")) {
              ref.read(alertProvider.notifier).disableAlerts(alertId: alertId);
            }
          } else {
            // update the alert state (beenRepliedTo set to true)
            final updatedAlert = widget.alert.copyWith(beenRepliedTo: true);
            ref.read(alertProvider.notifier).updateAlert(updatedAlert);
            CustomSnackBar.show(context, message: "Reply sent successfully", backgroundColor: const Color.fromRGBO(0, 128, 0, 1));
          }
          GoRouter.of(context).pop();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final replyState = ref.watch(replyToAlertProvider);

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 88),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, size: 30), onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 16),
                Flexible(child: Text(widget.alert.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'TittilumWeb'), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const Divider(color: Color.fromRGBO(208, 213, 221, 1), thickness: 1, height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      _isEditingText
                          // raise no error if there are no text
                          ? TextFormField(
                            controller: _messageController,
                            autofocus: true,
                            maxLines: 5,
                            decoration: const InputDecoration(hintText: "Type your reply here...", border: OutlineInputBorder()),
                          )
                          : GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingText = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 1), width: 1),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 3))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset('assets/images/T.png', height: 30, width: 30),
                                  const SizedBox(width: 8),
                                  const Text("Type", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color.fromRGBO(33, 33, 33, 1), fontFamily: 'Space Grotesk')),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 40),
                      _isRecording
                          ? GestureDetector(
                            onLongPress: _cancelRecording,
                            child: Row(
                              children: [
                                Expanded(child: WaveformRecorder(height: 60, controller: _waveController)),
                                const SizedBox(width: 16),
                                IconButton(icon: const Icon(Icons.stop, size: 30), onPressed: _stopRecording),
                              ],
                            ),
                          )
                          : GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 1), width: 1),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 3))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset('assets/images/voice.png', height: 30, width: 30),
                                  const SizedBox(width: 8),
                                  const Text("Record", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color.fromRGBO(33, 33, 33, 1), fontFamily: 'Space Grotesk')),
                                ],
                              ),
                            ),
                          ),

                      if (_isRecordingFinished) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            // play and pause button with animation
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                key: ValueKey(_isRecordingFinished),
                                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
                                onPressed: _isPlaying ? _stopPlayback : _playRecording,
                                tooltip: 'Play Recording',
                              ),
                            ),

                            // slider
                            Expanded(
                              child: Slider(
                                activeColor: const Color.fromRGBO(220, 9, 26, 1),
                                inactiveColor: const Color.fromRGBO(220, 9, 26, 0.5),
                                min: 0,
                                max: _totalDuration.inMilliseconds.toDouble(),
                                value: _currentPosition.inMilliseconds.clamp(0, _totalDuration.inMilliseconds).toDouble(),
                                onChanged: (value) async {
                                  await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                },
                              ),
                            ),
                            // left side time
                            Text(
                              _formatDuration(_totalDuration - _currentPosition),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color.fromRGBO(33, 33, 33, 1), fontFamily: 'Space Grotesk'),
                            ),
                            // delete button
                            IconButton(icon: const Icon(Icons.delete, size: 30), onPressed: _deleteRecording, tooltip: 'Delete Recording'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomElevatedButton(
                text: "Submit",
                onPressed:
                    replyState.isLoading
                        ? null
                        : () {
                          if (_isEditingText || _isRecordingFinished) {
                            _submitReply();
                          } else {
                            CustomSnackBar.show(context, message: "Please tap to type your reply");
                          }
                        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
