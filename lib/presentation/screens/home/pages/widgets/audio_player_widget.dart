import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:geoalert/core/storage/local_storage.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _playAudio() async {
    try {
      if (_currentFilePath == null) {
        setState(() {
          _isDownloading = true;
          _downloadProgress = 0;
        });

        final accessToken = await LocalStorage.instance.getAccessToken();
        final dio = Dio();

        // Create unique filename for each download
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final file = File(filePath);
        print("Audio url: ${widget.audioUrl}");
        // Download the file
        await dio.download(
          widget.audioUrl,
          // "https://example.com/audio.m4a", // Replace with your audio URL
          filePath,
          options: Options(headers: {if (accessToken != null) 'Authorization': 'Bearer $accessToken'}),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _downloadProgress = received / total;
              });
            }
          },
        );

        // Clean up previous file if exists
        if (_currentFilePath != null) {
          final previousFile = File(_currentFilePath!);
          if (await previousFile.exists()) {
            await previousFile.delete();
          }
        }

        setState(() {
          _currentFilePath = filePath;
          _isDownloading = false;
        });
      }
      // Play the audio
      await _audioPlayer.play(DeviceFileSource(_currentFilePath!));
    } on DioException catch (e) {
      setState(() {
        _isDownloading = false;
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: ${e.message}')));
      debugPrint('Dio error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playback error: ${e.toString()}')));
      debugPrint('Playback error: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // Clean up audio file
    if (_currentFilePath != null) {
      final file = File(_currentFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: _isDownloading ? const CircularProgressIndicator() : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed:
                  _isDownloading
                      ? null
                      : _isPlaying
                      ? _pauseAudio
                      : _playAudio,
            ),
            // IconButton(icon: const Icon(Icons.stop), onPressed: _isPlaying ? _stopAudio : null),
            if (_isDownloading)
              Expanded(child: LinearProgressIndicator(value: _downloadProgress, color: Color.fromRGBO(220, 9, 26, 1), backgroundColor: Color.fromRGBO(220, 9, 26, 0.5)))
            else
              Text(_isPlaying ? 'Playing...' : 'Tap to play'),
          ],
        ),
        if (_duration > Duration.zero)
          Column(
            children: [
              // make the slider move smoothly
              Slider(
                inactiveColor: Color.fromRGBO(220, 9, 26, 0.5),
                min: 0,
                max: _duration.inMilliseconds.toDouble(),
                value: _position.inMilliseconds.toDouble(),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatDuration(_position)), Text(_formatDuration(_duration - _position))]),
              ),
            ],
          ),
      ],
    );
  }
}
