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
  bool _playerReady = false;
  bool _isPlaying = false;

  void Function()? onPlaybackDone;

  bool get isPlaying => _isPlaying;

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
    _playQueue.add(Uint8List.fromList(chunk));
    _isPlaying = true;
    FlutterPcmSound.start();
  }

  void clearPlayback() {
    _playQueue.clear();
    _isPlaying = false;
  }

  void _onFeed(int remainingFrames) {
    if (_playQueue.isEmpty) {
      if (remainingFrames == 0 && _isPlaying) {
        _isPlaying = false;
        onPlaybackDone?.call();
      }
      return;
    }

    final chunk = _playQueue.removeAt(0);
    unawaited(
      FlutterPcmSound.feed(
        PcmArrayInt16(bytes: ByteData.sublistView(chunk)),
      ),
    );
  }

  Future<void> dispose() async {
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
