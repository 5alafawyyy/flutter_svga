import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Cache manager for SVGA files to improve loading performance.
/// Provides persistent disk caching for parsed SVGA data.
class SVGACache {
  static SVGACache? _instance;
  static SVGACache get shared => _instance ??= SVGACache._();

  SVGACache._();

  Directory? _cacheDir;
  bool _enabled = true;
  int _maxCacheSize = 100 * 1024 * 1024; // 100MB default
  Duration _maxAge = const Duration(days: 7); // 7 days default

  /// Whether caching is enabled. Defaults to true.
  bool get isEnabled => _enabled;

  /// Maximum cache size in bytes. Defaults to 100MB.
  int get maxCacheSize => _maxCacheSize;

  /// Maximum age for cached files. Defaults to 7 days.
  Duration get maxAge => _maxAge;

  /// Enable or disable caching.
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set maximum cache size in bytes.
  void setMaxCacheSize(int sizeInBytes) {
    _maxCacheSize = sizeInBytes;
  }

  /// Set maximum age for cached files.
  void setMaxAge(Duration duration) {
    _maxAge = duration;
  }

  /// Initialize cache directory
  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/svga_cache');
      
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      // If cache directory creation fails, disable caching
      _enabled = false;
    }
  }

  /// Generate cache key from source identifier
  String _generateCacheKey(String source) {
    return md5.convert(utf8.encode(source)).toString();
  }

  /// Get cache file path for a source
  Future<File?> _getCacheFile(String source) async {
    if (!_enabled) return null;
    
    await _ensureCacheDir();
    if (_cacheDir == null) return null;

    final key = _generateCacheKey(source);
    return File('${_cacheDir!.path}/$key.svga');
  }

  /// Check if cached data exists and is still valid
  Future<bool> _isCacheValid(File cacheFile) async {
    if (!await cacheFile.exists()) return false;
    
    final stat = await cacheFile.stat();
    final age = DateTime.now().difference(stat.modified);
    
    return age <= _maxAge;
  }

  /// Get cached raw bytes if available and valid
  Future<Uint8List?> getRawBytes(String source) async {
    if (!_enabled) return null;

    try {
      final cacheFile = await _getCacheFile(source);
      if (cacheFile == null) return null;

      if (!await _isCacheValid(cacheFile)) {
        // Remove expired cache
        await cacheFile.delete().catchError((_) => cacheFile);
        return null;
      }

      return await cacheFile.readAsBytes();
    } catch (e) {
      // If cache read fails, return null to fallback to normal loading
      return null;
    }
  }

  /// Store raw SVGA bytes in cache
  Future<void> putRawBytes(String source, Uint8List bytes) async {
    if (!_enabled) return;

    try {
      final cacheFile = await _getCacheFile(source);
      if (cacheFile == null) return;

      // Write the raw bytes to cache
      await cacheFile.writeAsBytes(bytes);

      // Clean up cache if needed
      await _cleanupCache();
    } catch (e) {
      // If cache write fails, silently continue without caching
    }
  }

  /// Remove specific item from cache
  Future<void> remove(String source) async {
    if (!_enabled) return;

    try {
      final cacheFile = await _getCacheFile(source);
      if (cacheFile != null && await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    if (!_enabled || _cacheDir == null) return;

    try {
      await _ensureCacheDir();
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get current cache size in bytes
  Future<int> getCacheSize() async {
    if (!_enabled || _cacheDir == null) return 0;

    try {
      await _ensureCacheDir();
      if (_cacheDir == null || !await _cacheDir!.exists()) return 0;

      int totalSize = 0;
      await for (final entity in _cacheDir!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clean up expired cache and enforce size limits
  Future<void> _cleanupCache() async {
    if (!_enabled || _cacheDir == null) return;

    try {
      await _ensureCacheDir();
      if (_cacheDir == null || !await _cacheDir!.exists()) return;

      final files = <File>[];
      await for (final entity in _cacheDir!.list()) {
        if (entity is File && entity.path.endsWith('.svga')) {
          files.add(entity);
        }
      }

      // Remove expired files
      final now = DateTime.now();
      for (final file in files.toList()) {
        final stat = await file.stat();
        if (now.difference(stat.modified) > _maxAge) {
          await file.delete().catchError((_) => file);
          files.remove(file);
        }
      }

      // Get file stats for sorting
      final fileStats = <File, FileStat>{};
      for (final file in files) {
        fileStats[file] = await file.stat();
      }

      // Sort by modification time (oldest first)
      files.sort((a, b) {
        final statA = fileStats[a]!;
        final statB = fileStats[b]!;
        return statA.modified.compareTo(statB.modified);
      });

      // Calculate total size
      int totalSize = 0;
      for (final file in files) {
        totalSize += fileStats[file]!.size;
      }

      // Remove oldest files until under size limit
      while (totalSize > _maxCacheSize && files.isNotEmpty) {
        final oldestFile = files.removeAt(0);
        final stat = fileStats[oldestFile]!;
        totalSize -= stat.size;
        await oldestFile.delete().catchError((_) => oldestFile);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    final size = await getCacheSize();
    int fileCount = 0;

    if (_enabled && _cacheDir != null) {
      try {
        await _ensureCacheDir();
        if (_cacheDir != null && await _cacheDir!.exists()) {
          await for (final entity in _cacheDir!.list()) {
            if (entity is File && entity.path.endsWith('.svga')) {
              fileCount++;
            }
          }
        }
      } catch (e) {
        // Silently fail
      }
    }

    return {
      'enabled': _enabled,
      'size': size,
      'maxSize': _maxCacheSize,
      'fileCount': fileCount,
      'maxAge': _maxAge.inDays,
    };
  }
}