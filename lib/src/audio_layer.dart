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
  double _volume;

  SVGAAudioLayer(this.audioItem, this._videoItem, {double initialVolume = 1.0})
    : _volume = initialVolume.clamp(0.0, 1.0);

  /// Current volume level of this audio layer (`0.0` to `1.0`).
  double get volume => _volume;

  /// Whether this audio layer has been disposed.
  bool get isDisposed => _disposed;

  Future<void> playAudio({double? volume}) async {
    if (_disposed) return;

    // Prevent duplicate playback if already playing or preparing to play
    if (_isReady || isPlaying()) return;

    if (volume != null) {
      _volume = volume.clamp(0.0, 1.0);
    }

    if (isPaused()) {
      try {
        await _player.setVolume(_volume);
        if (_disposed) return;
        await _player.resume();
      } catch (e) {
        log('Failed to resume audio: $e');
      }
      return;
    }

    final audioData = _videoItem.audiosData[audioItem.audioKey];
    if (audioData != null) {
      // https://github.com/bluefireteam/audioplayers/issues/1782
      // If need use Bytes, plz upgrade to audioplayers: ^6.0.0
      // BytesSource source = BytesSource(audioData);
      final cacheDir = await getApplicationCacheDirectory();
      if (_disposed) return;

      // Use MD5 hash to ensure unique cache files even when audioKeys collide
      // across different SVGA files with different audio content
      final audioHash = md5.convert(audioData).toString();
      final cacheFile = File(
        '${cacheDir.path}/temp_${audioItem.audioKey}_$audioHash.mp3',
      );

      if (!cacheFile.existsSync()) {
        await cacheFile.writeAsBytes(audioData);
      }
      if (_disposed) return;

      try {
        _isReady = true;
        await _player.setVolume(_volume);
        if (_disposed) {
          _isReady = false;
          return;
        }
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
  Future<void> setVolume(double volume) async {
    if (_disposed) return;
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
    } catch (e) {
      log('Failed to set audio volume: $e');
    }
  }

  void pauseAudio() {
    if (_disposed) return;
    if (isPlaying()) {
      _player.pause();
    }
  }

  void resumeAudio() {
    if (_disposed) return;
    if (isPaused()) {
      _player.resume();
    }
  }

  void stopAudio() {
    if (_disposed) return;
    if (isPlaying() || isPaused()) {
      _player.stop();
    }
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
    try {
      if (_player.state == PlayerState.playing ||
          _player.state == PlayerState.paused) {
        await _player.stop();
      }
    } catch (_) {}
    await _player.dispose();
  }
}
