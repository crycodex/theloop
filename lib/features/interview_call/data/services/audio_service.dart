import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart' as pcm;
import 'package:record/record.dart';

class InterviewAudioService {
  InterviewAudioService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final Queue<Uint8List> _playQueue = Queue<Uint8List>();
  StreamSubscription<Uint8List>? _micSubscription;
  bool _playerReady = false;
  bool _feeding = false;
  int _remainingFrames = 0;

  void Function()? onPlaybackDone;

  bool get isPlaying =>
      _feeding || _remainingFrames > 0 || _playQueue.isNotEmpty;

  Future<bool> requestMicrophonePermission() => _recorder.hasPermission();

  Future<void> setupPlayer() async {
    if (_playerReady) return;
    await pcm.FlutterPcmSound.setup(
      sampleRate: 24000,
      channelCount: 1,
      iosAudioCategory: pcm.IosAudioCategory.playAndRecord,
    );
    await pcm.FlutterPcmSound.setFeedThreshold(3600);
    pcm.FlutterPcmSound.setFeedCallback(_feedPlayer);
    _playerReady = true;
  }

  Future<void> startMic(void Function(Uint8List pcm) onData) async {
    await stopMic();
    await _recorder.ios?.manageAudioSession(false);
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
        autoGain: true,
        iosConfig: IosRecordConfig(
          categoryOptions: [
            IosAudioCategoryOption.allowBluetooth,
          ],
        ),
      ),
    );
    _micSubscription = stream.listen(onData);
  }

  Future<void> pauseMic() => _recorder.pause();

  Future<void> resumeMic() => _recorder.resume();

  Future<void> stopMic() async {
    await _micSubscription?.cancel();
    _micSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  void play(Uint8List chunk) {
    if (chunk.isEmpty) return;
    _playQueue.add(Uint8List.fromList(chunk));
    pcm.FlutterPcmSound.start();
  }

  void clearPlayback() {
    _playQueue.clear();
    if (_remainingFrames == 0 && !_feeding) {
      onPlaybackDone?.call();
    }
  }

  void _feedPlayer(int remainingFrames) {
    _remainingFrames = remainingFrames;
    if (_playQueue.isEmpty) {
      if (remainingFrames == 0) onPlaybackDone?.call();
      return;
    }

    final chunk = _playQueue.removeFirst();
    _feeding = true;
    unawaited(
      pcm.FlutterPcmSound.feed(
        pcm.PcmArrayInt16(
          bytes: chunk.buffer.asByteData(
            chunk.offsetInBytes,
            chunk.lengthInBytes,
          ),
        ),
      ).whenComplete(() => _feeding = false),
    );
  }

  Future<void> dispose() async {
    await stopMic();
    _playQueue.clear();
    pcm.FlutterPcmSound.setFeedCallback(null);
    if (_playerReady) await pcm.FlutterPcmSound.release();
    await _recorder.dispose();
  }
}
