import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'proto/svga.pb.dart';
import 'dart:io';

class SVGAAudioLayer {
  final AudioPlayer _player = AudioPlayer();
  late final AudioEntity audioItem;
  late final MovieEntity _videoItem;
  bool _isReady = false;
  bool _disposed = false;

  SVGAAudioLayer(this.audioItem, this._videoItem);

  Future<void> playAudio() async {
    if (_disposed) return;

    // Prevent duplicate playback if already playing or preparing to play
    if (_isReady || isPlaying()) return;

    final audioData = _videoItem.audiosData[audioItem.audioKey];
    if (audioData != null) {
      // https://github.com/bluefireteam/audioplayers/issues/1782
      // If need use Bytes, plz upgrade to audioplayers: ^6.0.0
      // BytesSource source = BytesSource(audioData);
      final cacheDir = await getApplicationCacheDirectory();
      final cacheFile = File('${cacheDir.path}/temp_${audioItem.audioKey}.mp3');

      if (!cacheFile.existsSync()) {
        await cacheFile.writeAsBytes(audioData);
      }

      try {
        _isReady = true;
        await _player.play(DeviceFileSource(cacheFile.path));
        _isReady = false;
        // I noticed that this logic exists in the iOS code of SVGAPlayer
        // but it seems unnecessary.
        // _player.seek(Duration(milliseconds: audioItem.startTime.toInt()));
      } catch (e) {
        _isReady = false;
        log('Failed to play audio: $e');
      }
    }
  }

  void pauseAudio() {
    if (_disposed) return;
    _player.pause();
  }

  void resumeAudio() {
    if (_disposed) return;
    _player.resume();
  }

  void stopAudio() {
    if (_disposed) return;
    if (isPlaying() || isPaused()) _player.stop();
  }

  bool isPlaying() {
    if (_disposed) return false;
    return _player.state == PlayerState.playing;
  }

  bool isPaused() {
    if (_disposed) return false;
    return _player.state == PlayerState.paused;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (isPlaying()) stopAudio();
    await _player.dispose();
  }
}
