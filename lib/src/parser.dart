import 'dart:developer';
import 'dart:ui' as ui;

import 'package:archive/archive.dart' as archive;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' show get;

import 'cache.dart';
import 'proto/svga.pbserver.dart';

const _filterKey = 'SVGAParser';

/// You use SVGAParser to load and decode animation files.
class SVGAParser {
  const SVGAParser();
  static const shared = SVGAParser();

  /// Download animation file from remote server, and decode it.
  /// Automatically uses cache if available and enabled.
  ///
  /// Set [useCache] to `false` to bypass reading from or writing to [SVGACache]
  /// for this specific request.
  Future<MovieEntity> decodeFromURL(String url, {bool useCache = true}) async {
    if (useCache) {
      final cachedBytes = await SVGACache.shared.getRawBytes(url);
      if (cachedBytes != null) {
        try {
          return await decodeFromBuffer(cachedBytes);
        } catch (_) {
          // Evict corrupted cache data and fallback to network fetch
          await SVGACache.shared.remove(url);
        }
      }
    }

    // Download and verify HTTP status before decoding
    final response = await get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load SVGA from URL ($url): HTTP ${response.statusCode}',
      );
    }
    final bytes = response.bodyBytes;
    final movie = await decodeFromBuffer(bytes);

    // Cache the raw response bytes after successful decoding
    if (useCache) {
      await SVGACache.shared.putRawBytes(url, Uint8List.fromList(bytes));
    }

    return movie;
  }

  /// Download animation file from bundle assets, and decode it.
  /// Automatically uses cache if available and enabled.
  ///
  /// Set [useCache] to `false` to bypass reading from or writing to [SVGACache]
  /// for this specific request.
  Future<MovieEntity> decodeFromAssets(
    String path, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedBytes = await SVGACache.shared.getRawBytes('assets:$path');
      if (cachedBytes != null) {
        try {
          return await decodeFromBuffer(cachedBytes);
        } catch (_) {
          await SVGACache.shared.remove('assets:$path');
        }
      }
    }

    // Load from assets
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final movie = await decodeFromBuffer(bytes);

    // Cache the asset bytes after successful decoding
    if (useCache) {
      await SVGACache.shared.putRawBytes('assets:$path', bytes);
    }

    return movie;
  }

  /// Download animation file from buffer, and decode it.
  Future<MovieEntity> decodeFromBuffer(List<int> bytes) {
    TimelineTask? timeline;
    if (!kReleaseMode) {
      timeline = TimelineTask(filterKey: _filterKey)
        ..start('DecodeFromBuffer', arguments: {'length': bytes.length});
    }
    final inflatedBytes = const archive.ZLibDecoder().decodeBytes(bytes);
    if (timeline != null) {
      timeline.instant(
        'MovieEntity.fromBuffer()',
        arguments: {'inflatedLength': inflatedBytes.length},
      );
    }
    final movie = MovieEntity.fromBuffer(inflatedBytes);
    if (timeline != null) {
      timeline.instant(
        'prepareResources()',
        arguments: {'images': movie.images.keys.join(',')},
      );
    }
    return _prepareResources(
      _processShapeItems(movie),
      timeline: timeline,
    ).whenComplete(() {
      if (timeline != null) timeline.finish();
    });
  }

  MovieEntity _processShapeItems(MovieEntity movieItem) {
    for (var sprite in movieItem.sprites) {
      List<ShapeEntity>? lastShape;
      for (var frame in sprite.frames) {
        if (frame.shapes.isNotEmpty) {
          if (frame.shapes[0].type == ShapeEntity_ShapeType.KEEP &&
              lastShape != null) {
            frame.shapes = lastShape;
          } else if (frame.shapes.isNotEmpty) {
            lastShape = frame.shapes;
          }
        }
      }
    }
    return movieItem;
  }

  Future<MovieEntity> _prepareResources(
    MovieEntity movieItem, {
    TimelineTask? timeline,
  }) {
    final images = movieItem.images;
    if (images.isEmpty) {
      movieItem.releaseMemory();
      return Future.value(movieItem);
    }
    return Future.wait(
      images.entries.map((item) async {
        // result null means a decoding error occurred
        Uint8List data = Uint8List.fromList(item.value);
        if (isMP3Data(data)) {
          movieItem.audiosData[item.key] = data;
        } else {
          final decodeImage = await _decodeImageItem(
            item.key,
            data,
            timeline: timeline,
          );
          if (decodeImage != null) {
            movieItem.bitmapCache[item.key] = decodeImage;
          }
        }
      }),
    ).then((_) {
      // Release protobuf internal structures to reduce memory
      movieItem.releaseMemory();
      return movieItem;
    });
  }

  Future<ui.Image?> _decodeImageItem(
    String key,
    Uint8List bytes, {
    TimelineTask? timeline,
  }) async {
    TimelineTask? task;
    if (!kReleaseMode) {
      task = TimelineTask(filterKey: _filterKey, parent: timeline)
        ..start('DecodeImage', arguments: {'key': key, 'length': bytes.length});
    }
    try {
      final image = await decodeImageFromList(bytes);
      if (task != null) {
        task.finish(arguments: {'imageSize': '${image.width}x${image.height}'});
      }
      return image;
    } catch (e, stack) {
      if (task != null) {
        task.finish(arguments: {'error': '$e', 'stack': '$stack'});
      }
      assert(() {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: stack,
            library: 'svgaplayer',
            context: ErrorDescription('during prepare resource'),
            informationCollector: () sync* {
              yield ErrorSummary('Decoding image failed.');
            },
          ),
        );
        return true;
      }());
      return null;
    }
  }

  bool isMP3Data(Uint8List data) {
    if (data.length < 3) return false;
    const mp3MagicNumber = 'ID3';
    if (String.fromCharCodes(data.take(mp3MagicNumber.length)) ==
        mp3MagicNumber) {
      return true;
    }
    // Also detect raw MPEG audio frame sync (0xFF followed by 0xE0..0xFF)
    if (data[0] == 0xFF && (data[1] & 0xE0) == 0xE0) {
      return true;
    }
    return false;
  }
}
