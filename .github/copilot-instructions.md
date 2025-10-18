# Flutter SVGA Package - AI Agent Instructions

## Project Overview
This is a Flutter package for parsing and rendering SVGA (Simple Vector Graphics Animation) files. SVGA is a lightweight animation format that supports dynamic content replacement, audio playback, and efficient mobile rendering.

## Core Architecture

### Key Components Flow
1. **Parser** (`lib/src/parser.dart`) - Entry point for loading SVGA files
   - `SVGAParser.shared.decodeFromAssets()` - Load from app bundle
   - `SVGAParser.shared.decodeFromURL()` - Load from network  
   - `SVGAParser.shared.decodeFromBuffer()` - Load from raw bytes
   - Handles ZLib decompression and protobuf parsing internally
   - **Automatic caching** - transparently caches parsed data for performance

2. **Cache System** (`lib/src/cache.dart`) - Persistent storage for performance
   - `SVGACache.shared` - Global cache instance with intelligent management
   - Automatic cache checking in parser methods (zero breaking changes)
   - Configurable size limits, expiration, and manual management
   - Stores raw SVGA bytes with MD5-hashed filenames in temp directory

3. **Player Components** (`lib/src/player.dart`)
   - `SVGAAnimationController` - Extends Flutter's AnimationController for playback control
   - `SVGAImage` - Widget that renders the animation using CustomPainter
   - `SVGAEasyPlayer` - Simplified widget that handles loading and auto-plays

4. **Protocol Buffers** (`lib/src/proto/`)
   - Generated from `.proto` files - **NEVER edit these manually**
   - `MovieEntity` - Root animation data structure
   - `SpriteEntity`, `ShapeEntity`, `FrameEntity` - Animation hierarchy
   - Excluded from linting via `analysis_options.yaml`

5. **Dynamic Content** (`lib/src/dynamic_entity.dart`)
   - Replace text: `entity.dynamicItem.setText(TextPainter(...), "layerName")`
   - Replace images: `entity.dynamicItem.setImageWithUrl(url, "layerName")`
   - Hide layers: `entity.dynamicItem.setHidden(true, "layerName")`
   - Custom drawing: `entity.dynamicItem.setDynamicDrawer(drawer, "layerName")`

### Critical Patterns

#### Animation Controller Lifecycle
```dart
class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late SVGAAnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    // ALWAYS set videoItem before calling animation methods
    SVGAParser.shared.decodeFromAssets("assets/sample.svga").then((video) {
      _controller.videoItem = video;  // This sets duration automatically
      _controller.repeat();  // Now safe to animate
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();  // Critical: prevents memory leaks
    super.dispose();
  }
}
```

#### Easy Player Pattern (Recommended for simple use cases)
```dart
SVGAEasyPlayer(
  assetsName: "assets/animation.svga",  // OR
  resUrl: "https://example.com/animation.svga",
  fit: BoxFit.contain,
)
```

## Development Conventions

### File Organization
- Main exports in `lib/flutter_svga.dart` - only expose public API
- Implementation in `lib/src/` - internal details  
- `part`/`part of` used to split large files (see `player.dart` + `easy_player.dart`)
- Protocol buffer files auto-generated, never manually edited

### Error Handling Patterns
- Use `FlutterError.reportError()` for runtime errors that should appear in crash reports
- Timeline profiling with `TimelineTask` in debug mode for performance monitoring
- Graceful degradation: return null for failed image decoding rather than crashing

### Memory Management
- `MovieEntity.autorelease` flag controls automatic disposal
- Images cached in `MovieEntity.bitmapCache` as `ui.Image` objects
- Audio data stored separately in `MovieEntity.audiosData` 
- Always dispose controllers to prevent memory leaks

### Testing Approach
- Minimal unit tests in `test/` - focus on package loading verification
- Heavy reliance on example app in `example/` for integration testing
- Asset-based testing with sample SVGA files in `example/assets/`

## Common Pitfalls

1. **Setting videoItem vs duration**: Setting `controller.videoItem` automatically calculates duration from SVGA metadata. Don't set duration manually.

2. **Dynamic content timing**: Apply dynamic modifications to `MovieEntity` before assigning to controller, not during animation.

3. **Asset registration**: SVGA files must be declared in `pubspec.yaml` under `flutter: assets:` to load from assets.

4. **Audio support limitations**: Web platform doesn't support audio playback - check platform capabilities.

5. **Protocol buffer regeneration**: If modifying `.proto` files, regenerate using `protoc` with the exact flags used originally.

## Key Dependencies
- `protobuf: ^4.1.0` - Core protobuf support (v4+ required)
- `archive: ^4.0.7` - ZLib decompression of SVGA files  
- `path_drawing: ^1.0.1` - Vector path rendering
- `audioplayers: ^6.5.0` - Audio playback in animations
- `http: ^1.4.0` - Network resource loading
- `path_provider: ^2.1.5` - Cache directory access for persistent storage
- `crypto: ^3.0.5` - MD5 hashing for cache keys

## Platform Support Matrix
- ✅ Android/iOS: Full support including audio
- ✅ Desktop (Linux/macOS/Windows): Full support with audio  
- ⚠️  Web: Animation support only, no audio playback

When working on this package, prioritize performance and memory efficiency - SVGA is designed for mobile platforms where resources are constrained.