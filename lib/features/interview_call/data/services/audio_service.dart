import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart' as pcm;
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart'
    show FlutterPcmSound, LogLevel, PcmArrayInt16;
import 'package:record/record.dart';

class InterviewAudioService {
  InterviewAudioService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final List<Uint8List> _playQueue = [];
  StreamSubscription<Uint8List>? _micSubscription;
  Timer? _playbackIdleTimer;
  int _pendingPlaybackBytes = 0;
  bool _playerReady = false;
  bool _isPlaying = false;

  void Function()? onPlaybackDone;

  bool get isPlaying => _isPlaying;

  /// Estima cuánto dura reproducir un chunk PCM 16-bit mono a 24 kHz.
  Duration estimatedPlaybackDelay(Uint8List chunk) {
    if (chunk.isEmpty) return const Duration(milliseconds: 300);
    final ms = (chunk.length / (24000 * 2) * 1000).ceil() + 200;
    return Duration(milliseconds: ms.clamp(250, 8000));
  }

  Future<bool> requestMicrophonePermission() =>
      _recorder.hasPermission();

  Future<void> setupPlayer() async {
    if (_playerReady) return;
    await FlutterPcmSound.setLogLevel(LogLevel.error);
    await FlutterPcmSound.setup(
      sampleRate: 24000,
      channelCount: 1,
      iosAudioCategory: pcm.IosAudioCategory.playAndRecord,
    );
    await FlutterPcmSound.setFeedThreshold(3600);
    FlutterPcmSound.setFeedCallback(_onFeed);
    _playerReady = true;
  }

  Future<void> startMic(void Function(Uint8List pcm) onData) async {
    await stopMic();
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );
    _micSubscription = stream.listen(onData);
  }

  Future<void> stopMic() async {
    await _micSubscription?.cancel();
    _micSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  void play(Uint8List chunk) {
    if (!_playerReady || chunk.isEmpty) return;
    _playbackIdleTimer?.cancel();
    _pendingPlaybackBytes += chunk.length;
    _playQueue.add(Uint8List.fromList(chunk));
    _isPlaying = true;
    FlutterPcmSound.start();
  }

  void clearPlayback() {
    _playbackIdleTimer?.cancel();
    _playQueue.clear();
    _pendingPlaybackBytes = 0;
    _markPlaybackIdle();
  }

  void _onFeed(int remainingFrames) {
    while (_playQueue.isNotEmpty) {
      final chunk = _playQueue.removeAt(0);
      unawaited(
        FlutterPcmSound.feed(
          PcmArrayInt16(bytes: ByteData.sublistView(chunk)),
        ),
      );
    }

    if (!_isPlaying) return;

    _playbackIdleTimer?.cancel();
    if (remainingFrames == 0 && _playQueue.isEmpty) {
      _markPlaybackIdle();
      return;
    }

    if (_playQueue.isEmpty) {
      final ms = (_pendingPlaybackBytes / (24000 * 2) * 1000).ceil() + 150;
      _playbackIdleTimer = Timer(
        Duration(milliseconds: ms.clamp(200, 8000)),
        () {
          if (_playQueue.isEmpty) _markPlaybackIdle();
        },
      );
    }
  }

  void _markPlaybackIdle() {
    if (!_isPlaying) return;
    _playbackIdleTimer?.cancel();
    _pendingPlaybackBytes = 0;
    _isPlaying = false;
    onPlaybackDone?.call();
  }

  Future<void> dispose() async {
    _playbackIdleTimer?.cancel();
    await stopMic();
    _playQueue.clear();
    FlutterPcmSound.setFeedCallback(null);
    if (_playerReady) {
      _playerReady = false;
      await FlutterPcmSound.release();
    }
    await _recorder.dispose();
  }
}
