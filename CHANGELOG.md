## [0.0.14] - 2026-10-16

### 🚀 New Features

- **Enhanced Audio & Volume Architecture** (#9, PR #10):
  - Added initial `volume` and `muted` parameters to `SVGAAnimationController` constructor
  - Added `effectiveVolume` getter and `toggleMute()` helper on `SVGAAnimationController`
  - Added declarative `volume` and `muted` controls to `SVGAEasyPlayer`
  - Added interactive Audio Volume slider and Mute toggle to the example app
  - Thanks to [@Sansuihe](https://github.com/Sansuihe) for PR #10!
- **Pause & Resume Playback**:
  - Added `controller.pause()`, `controller.resume()`, and `controller.isPaused` to pause and resume animations and synchronized audio layers seamlessly
- **Expanded `SVGAEasyPlayer` Capabilities**:
  - Added `loops`, `dynamicCallback`, `onFinished`, `filterQuality`, `allowDrawingOverflow`, `clearsAfterStop`, and `preferredSize`
- **Per-Request Cache Control**:
  - Added optional `useCache` parameter to `SVGAParser.decodeFromURL` and `SVGAParser.decodeFromAssets`

### 🛠 Fixes & Hardening

- **Safe Network Caching & Corrupted Cache Recovery**: Verify HTTP 200 status before decoding/caching and automatically evict corrupted cache entries on decode failure
- **Renderer Range & Path Safety** (#11): Guard sprite frame bounds, clamp RGBA/alpha channels for non-standard SVGA exporters, and support multi-space/scientific-notation SVG paths
- **MP3 Frame Sync Detection**: Detect both `ID3`-tagged and raw MPEG frame-sync (`0xFF 0xE0`) audio streams in `SVGAParser.isMP3Data`
- **Audio Layer Lifecycle**: Properly dispose and clear existing audio layers when reassigning `SVGAAnimationController.videoItem` or calling `reset()`, and guard async gaps against post-dispose calls

### 📦 SDK, Dependencies & Tests

- **Updated Flutter & Dart SDK**: Upgraded to Flutter `3.47.7` and Dart SDK constraint `^3.13.5`
- **Updated Dependencies**: `archive: ^4.5.2`, `protobuf: ^6.1.0`, `audioplayers: ^6.8.1`, `path_provider: ^2.1.6`
- **Comprehensive Test Suite**: Added unit and widget tests covering volume/mute control, pause/resume lifecycle, memory release, dynamic entities, caching, MP3 detection, and widgets
- **Professional Documentation**: Redesigned `README.md` with badges, feature guides, and API reference tables

---

## [0.0.13] - 2026-01-20

### 🚀 New Features

- **Volume Control** (#9, PR #10): Added audio volume control to `SVGAAnimationController`
  - `controller.volume = 0.5` — Set volume level (0.0 to 1.0)
  - `controller.muted = true/false` — Toggle mute without losing volume setting
  - Thanks to [@Sansuihe](https://github.com/Sansuihe) for the contribution!

### ⚡ Performance Improvements

- **Memory Optimization** (#8): Reduced Dart heap memory usage by clearing protobuf internal structures after parsing
  - Added `freeze()` method to `MovieEntity` that clears raw image data after extraction
  - Addresses high memory from `FieldSet`, `PbList`, and `FrameEntity` instances
  - Thanks to [@jianleepb](https://github.com/jianleepb) for reporting!

---

## [0.0.12] - 2025-12-24

### 🚀 Improvements

- **Updated Dart SDK constraint** to `^3.10.4` for compatibility with Flutter 3.38.5

### 📝 Maintenance

- **Shortened package description** for pub.dev compliance (under 180 characters)
- **Fixed lint warnings** in generated protobuf files by adding `no_leading_underscores_for_local_identifiers` to ignore rules

---

## [0.0.11] - 2025-12-10

### 📝 Documentation

- **Enhanced README with competitive positioning**
  - Added "Why flutter_svga?" section highlighting active maintenance vs archived `svgaplayer_flutter`
  - Added comparison table (flutter_svga vs svgaplayer_flutter vs Lottie)
  - Added migration guide for users switching from `svgaplayer_flutter`
  
- **Improved SEO & Discoverability**
  - Updated `pubspec.yaml` description with better keywords (actively maintained, alternative, replacement)
  - Added relevant topics: animation, svga, vector-graphics, lottie-alternative, ui-effects

---

## [0.0.10] - 2025-12-03

### 📝 Documentation
- Updated README to version 0.0.10 for pub.dev visibility
- Added contributors @Sansuihe and @tungpham6195 to README

---

## [0.0.9] - 2025-12-03

### 🛠 Fixes
- Fixed audio cache collision bug where different SVGA files with the same `audioKey` but different audio content incorrectly shared cached files (#6).  
  Now uses MD5 hash of audio data to ensure unique cache files.  
  (Thanks to [@Sansuihe](https://github.com/Sansuihe) for reporting and suggesting the fix.)

### 🚀 Improvements
- Protobuf dependency updated to `^6.0.0`, ensuring compatibility with `retrofit_generator >=10.1.0` (#7).  
  (Thanks to [@tungpham6195](https://github.com/tungpham6195) for reporting.)

---

## [0.0.8] - 2025-10-18


### 🛠 Fixes
- Fixed repeated music playback bug when reusing the same audio key.  
  (Thanks to [@wonderkidshihab](https://github.com/wonderkidshihab) for the PR and [@Sansuihe](https://github.com/Sansuihe) for reporting.)

### 🚀 Improvements
- Optimized audio handling and cache logic for better playback stability.
- Updated README and credits for contributors.
- Version bump for pub.dev publication.

---

## [0.0.7] - 2025-10-18

### Fixed
- 🎵 Fixed repeated music playback bug when same audio keys are used (#3)
- 🛡️ Improved race condition handling in audio playback logic
- ✅ Added early return check to prevent duplicate audio playback

### Maintenance
- Enhanced audio layer synchronization and error handling

---


## [0.0.6] - 2025-06-26

### Fixed
- 🎧 Prevent crash when AudioPlayer is accessed after dispose (#1)
- 🛠️ Updated to support protobuf 4+, other latest dependencies and use Flutter 3.32.5 (#2)

### Maintenance
- Improved safety checks in SVGAAudioLayer
- Compatible with Dart 3.0 and Flutter 3.32+

---

## 0.0.5 - Update (2025-03-14)

### 🔥 Upgrade to flutter version 3.29.2

---

## 0.0.4 - Update (2025-02-09)

### 🔥 New Features & Improvements
- ✅ **Added Audio Support**: Integrated audio playback within SVGA animations using the `audioplayers` package.

---

## 0.0.3 - Update (2025-01-30)

### 🔥 New Features & Improvements
- ✅ **Added Pause & Resume Playback Functions** for SVGA animations.
- ✅ **Enhanced Error Handling & Logging** for better debugging.
- ✅ **Improved Performance** when loading SVGA animations.

### 🛠 Fixes & Optimizations
- 🛠 Fixed potential crashes when loading SVGA assets.
- 🛠 Optimized memory usage for large SVGA files.
- 🛠 Improved logging messages for debugging.

---

## 0.0.2 - Update (2025-01-30)

### 🔥 Updates & Improvements
- ✅ Added **example GIFs** for better demonstration.
- ✅ **Supported all platforms** including **Web & Desktop**.

---

## 0.0.1 - Initial Release (2025-01-29)

### 🎉 New Features
- ✅ Added support for **SVGA parsing and rendering**.
- ✅ Load **SVGA animations** from **assets** and **network URLs**.
- ✅ Implemented **SVGAAnimationController** for playback control.
- ✅ Dynamic entity support (text & images).
- ✅ Optimized performance for **smooth animations**.
