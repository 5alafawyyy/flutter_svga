import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:flutter_test/flutter_test.dart';

MovieEntity _createTestMovieEntity({
  double width = 200,
  double height = 200,
  int fps = 20,
  int frames = 40,
}) {
  return MovieEntity(
    version: '2.0',
    params: MovieParams(
      viewBoxWidth: width,
      viewBoxHeight: height,
      fps: fps,
      frames: frames,
    ),
  );
}

void main() {
  group('SVGAAnimationController - Volume & Mute Control', () {
    testWidgets('defaults to volume 1.0 and unmuted', (tester) async {
      final controller = SVGAAnimationController(vsync: tester);
      addTearDown(controller.dispose);

      expect(controller.volume, 1.0);
      expect(controller.muted, isFalse);
      expect(controller.effectiveVolume, 1.0);
    });

    testWidgets('supports initial volume and muted in constructor', (
      tester,
    ) async {
      final controller = SVGAAnimationController(
        vsync: tester,
        volume: 0.4,
        muted: true,
      );
      addTearDown(controller.dispose);

      expect(controller.volume, 0.4);
      expect(controller.muted, isTrue);
      expect(controller.effectiveVolume, 0.0);
    });

    testWidgets('clamps volume between 0.0 and 1.0', (tester) async {
      final controller = SVGAAnimationController(vsync: tester, volume: 2.5);
      addTearDown(controller.dispose);

      expect(controller.volume, 1.0);

      controller.volume = -0.5;
      expect(controller.volume, 0.0);

      controller.volume = 0.75;
      expect(controller.volume, 0.75);

      controller.volume = 1.8;
      expect(controller.volume, 1.0);
    });

    testWidgets('muted and toggleMute preserve underlying volume setting', (
      tester,
    ) async {
      final controller = SVGAAnimationController(vsync: tester);
      addTearDown(controller.dispose);

      controller.volume = 0.65;
      expect(controller.effectiveVolume, 0.65);

      controller.muted = true;
      expect(controller.muted, isTrue);
      expect(controller.volume, 0.65);
      expect(controller.effectiveVolume, 0.0);

      controller.toggleMute();
      expect(controller.muted, isFalse);
      expect(controller.volume, 0.65);
      expect(controller.effectiveVolume, 0.65);
    });
  });

  group('SVGAAnimationController - Playback & Lifecycle', () {
    testWidgets('computes duration and frames when videoItem is assigned', (
      tester,
    ) async {
      final controller = SVGAAnimationController(vsync: tester);
      addTearDown(controller.dispose);

      expect(controller.frames, 0);
      expect(controller.currentFrame, 0);
      expect(controller.duration, Duration.zero);

      final movie = _createTestMovieEntity(fps: 20, frames: 40);
      controller.videoItem = movie;

      expect(controller.frames, 40);
      expect(controller.duration, const Duration(milliseconds: 2000));
      expect(controller.currentFrame, 0);

      controller.value = 0.5;
      expect(controller.currentFrame, 20);
    });

    testWidgets('supports pause and resume lifecycle', (tester) async {
      final controller = SVGAAnimationController(vsync: tester);

      controller.videoItem = _createTestMovieEntity(fps: 20, frames: 20);
      controller.repeat();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(controller.isAnimating, isTrue);
      expect(controller.isPaused, isFalse);

      final pausedValue = controller.value;
      controller.pause();

      expect(controller.isAnimating, isFalse);
      expect(controller.isPaused, isTrue);
      expect(controller.value, closeTo(pausedValue, 0.001));

      controller.resume();
      await tester.pump();

      expect(controller.isAnimating, isTrue);
      expect(controller.isPaused, isFalse);

      controller.dispose();
    });

    testWidgets('safely ignores mutations after dispose', (tester) async {
      final controller = SVGAAnimationController(vsync: tester);
      controller.videoItem = _createTestMovieEntity();
      controller.dispose();

      expect(controller.isDisposed, isTrue);
      expect(controller.videoItem, isNull);

      controller.volume = 0.2;
      controller.muted = true;
      expect(controller.volume, 1.0);
      expect(controller.muted, isFalse);
    });
  });

  group('MovieEntity & SVGADynamicEntity', () {
    test('releaseMemory clears raw images map', () {
      final movie = _createTestMovieEntity();
      movie.images['key1'] = <int>[1, 2, 3, 4];

      expect(movie.images.isNotEmpty, isTrue);
      expect(movie.isMemoryReleased, isFalse);

      movie.releaseMemory();

      expect(movie.isMemoryReleased, isTrue);
      expect(movie.images.isEmpty, isTrue);
    });

    test('SVGADynamicEntity manages dynamic layers and resets cleanly', () {
      final dynamicEntity = SVGADynamicEntity();
      final painter = TextPainter(text: const TextSpan(text: 'Test SVGA'));

      dynamicEntity.setHidden(true, 'hidden_layer');
      dynamicEntity.setText(painter, 'text_layer');
      dynamicEntity.setDynamicDrawer((_, _) {}, 'drawer_layer');

      expect(dynamicEntity.dynamicHidden['hidden_layer'], isTrue);
      expect(dynamicEntity.dynamicText['text_layer'], same(painter));
      expect(painter.textDirection, TextDirection.ltr);
      expect(dynamicEntity.dynamicDrawer['drawer_layer'], isNotNull);

      dynamicEntity.reset();

      expect(dynamicEntity.dynamicHidden, isEmpty);
      expect(dynamicEntity.dynamicText, isEmpty);
      expect(dynamicEntity.dynamicDrawer, isEmpty);
      expect(dynamicEntity.dynamicImages, isEmpty);
    });
  });

  group('SVGAParser & SVGACache', () {
    test('SVGAParser.isMP3Data detects ID3 and MPEG frame sync headers', () {
      const parser = SVGAParser.shared;

      final id3Bytes = Uint8List.fromList([0x49, 0x44, 0x33, 0x03, 0x00]);
      final mpegSyncBytes = Uint8List.fromList([0xFF, 0xFB, 0x90, 0x64]);
      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

      expect(parser.isMP3Data(id3Bytes), isTrue);
      expect(parser.isMP3Data(mpegSyncBytes), isTrue);
      expect(parser.isMP3Data(pngBytes), isFalse);
      expect(parser.isMP3Data(Uint8List(0)), isFalse);
    });

    test('SVGACache configuration getters and setters', () {
      final cache = SVGACache.shared;
      addTearDown(() {
        cache.setEnabled(true);
        cache.setMaxCacheSize(100 * 1024 * 1024);
        cache.setMaxAge(const Duration(days: 7));
      });

      cache.setEnabled(false);
      cache.setMaxCacheSize(25 * 1024 * 1024);
      cache.setMaxAge(const Duration(days: 2));

      expect(cache.isEnabled, isFalse);
      expect(cache.maxCacheSize, 25 * 1024 * 1024);
      expect(cache.maxAge, const Duration(days: 2));
    });
  });

  group('SVGAImage & SVGAEasyPlayer Widgets', () {
    testWidgets('SVGAImage renders CustomPaint when MovieEntity is valid', (
      tester,
    ) async {
      final controller = SVGAAnimationController(vsync: tester);
      addTearDown(controller.dispose);
      controller.videoItem = _createTestMovieEntity(width: 150, height: 150);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SVGAImage(controller, preferredSize: const Size(150, 150)),
          ),
        ),
      );

      expect(find.byType(SVGAImage), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('SVGAEasyPlayer configures volume, muted, and loops', (
      tester,
    ) async {
      const player = SVGAEasyPlayer(
        volume: 0.3,
        muted: true,
        loops: false,
        fit: BoxFit.cover,
      );

      await tester.pumpWidget(
        const Directionality(textDirection: TextDirection.ltr, child: player),
      );

      expect(find.byType(SVGAEasyPlayer), findsOneWidget);
      expect(player.volume, 0.3);
      expect(player.muted, isTrue);
      expect(player.loops, isFalse);
      expect(player.fit, BoxFit.cover);
    });
  });
}
