import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import 'proto/svga.pb.dart';

class SVGAAudioLayer {
  final AudioPlayer _player = AudioPlayer();
  late final AudioEntity audioItem;
  late final MovieEntity _videoItem;
  bool _isReady = false;
  bool _disposed = false;
  double _volume = 1.0;

  SVGAAudioLayer(this.audioItem, this._videoItem);

  Future<void> playAudio({double? volume}) async {
    if (_disposed) return;

    // Prevent duplicate playback if already playing or preparing to play
    if (_isReady || isPlaying()) return;

    final audioData = _videoItem.audiosData[audioItem.audioKey];
    if (audioData != null) {
      // https://github.com/bluefireteam/audioplayers/issues/1782
      // If need use Bytes, plz upgrade to audioplayers: ^6.0.0
      // BytesSource source = BytesSource(audioData);
      final cacheDir = await getApplicationCacheDirectory();

      // Use MD5 hash to ensure unique cache files even when audioKeys collide
      // across different SVGA files with different audio content
      final audioHash = md5.convert(audioData).toString();
      final cacheFile = File(
        '${cacheDir.path}/temp_${audioItem.audioKey}_$audioHash.mp3',
      );

      if (!cacheFile.existsSync()) {
        await cacheFile.writeAsBytes(audioData);
      }

      try {
        _isReady = true;
        // Apply volume before playing
        if (volume != null) {
          _volume = volume.clamp(0.0, 1.0);
        }
        await _player.setVolume(_volume);
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

  /// Sets the volume for this audio layer.
  /// [volume] should be between 0.0 (mute) and 1.0 (max volume).
  void setVolume(double volume) {
    if (_disposed) return;
    _volume = volume.clamp(0.0, 1.0);
    _player.setVolume(_volume);
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
