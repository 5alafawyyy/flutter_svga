# SVGA Cache Feature

The Flutter SVGA package now includes powerful caching capabilities that automatically improve performance by storing parsed SVGA files locally. This feature is **completely backward compatible** - existing code continues to work unchanged.

## 🚀 Key Benefits

- **Faster loading**: Cached animations load instantly on subsequent requests
- **Reduced network usage**: Downloads are avoided when cache is available  
- **Persistent storage**: Cache survives app restarts
- **Automatic management**: Smart cleanup based on size limits and expiration
- **Zero breaking changes**: Works seamlessly with existing code

## 📋 Quick Start

Caching is **enabled by default** and works automatically:

```dart
// This automatically uses cache if available, downloads if not
final animation = await SVGAParser.shared.decodeFromURL(
  'https://example.com/animation.svga'
);

// Assets are also cached for faster subsequent loads
final assetAnimation = await SVGAParser.shared.decodeFromAssets(
  'assets/my_animation.svga'
);
```

## ⚙️ Configuration (Optional)

You can customize cache behavior:

```dart
import 'package:flutter_svga/flutter_svga.dart';

void configureSVGACache() {
  // Enable/disable caching (default: true)
  SVGACache.shared.setEnabled(true);
  
  // Set maximum cache size (default: 100MB)
  SVGACache.shared.setMaxCacheSize(50 * 1024 * 1024); // 50MB
  
  // Set maximum age for cached files (default: 7 days)
  SVGACache.shared.setMaxAge(const Duration(days: 3)); // 3 days
}
```

## 🔧 Cache Management

### Clear Specific Items
```dart
// Remove specific animation from cache
await SVGACache.shared.remove('https://example.com/animation.svga');
```

### Clear All Cache
```dart
// Clear entire cache
await SVGACache.shared.clear();
```

### Get Cache Statistics
```dart
final stats = await SVGACache.shared.getStats();
print('Cache size: ${stats['size']}');
print('File count: ${stats['fileCount']}');
print('Enabled: ${stats['enabled']}');
```

## 🏗️ Architecture

The cache system operates at the raw data level:

1. **Cache Check**: Parser first checks if cached data exists and is valid
2. **Load & Cache**: If not cached, loads from source and stores for future use
3. **Automatic Cleanup**: Removes expired files and enforces size limits
4. **Transparent Operation**: No changes needed to existing parser usage

## 📁 Cache Storage

- **Location**: Uses platform's temporary directory (`path_provider`)
- **Format**: Raw SVGA bytes with MD5-based filenames
- **Persistence**: Survives app restarts and updates
- **Security**: Cache keys are hashed for privacy

## 🔄 Cache Lifecycle

### Automatic Cleanup
- **Expiration**: Files older than `maxAge` are automatically removed
- **Size Limits**: Oldest files are removed when cache exceeds `maxCacheSize`
- **Cleanup Timing**: Occurs during cache write operations

### Cache Keys
- **Network URLs**: Use the full URL as cache key
- **Assets**: Prefixed with `assets:` + path (e.g., `assets:animations/sample.svga`)

## 🎯 Best Practices

### For Network Resources
```dart
// URLs are automatically cached - no code changes needed
final networkAnimation = await SVGAParser.shared.decodeFromURL(
  'https://cdn.example.com/animations/loading.svga'
);
```

### For Asset Resources
```dart
// Assets are cached to speed up subsequent app launches
final assetAnimation = await SVGAParser.shared.decodeFromAssets(
  'assets/splash_animation.svga'
);
```

### Cache Configuration at App Startup
```dart
void main() {
  // Configure cache before first use
  SVGACache.shared.setMaxCacheSize(200 * 1024 * 1024); // 200MB
  SVGACache.shared.setMaxAge(const Duration(days: 14)); // 2 weeks
  
  runApp(MyApp());
}
```

## 🔍 Debugging Cache

### Check if Caching is Working
```dart
// Load an animation twice and compare timing
final stopwatch = Stopwatch()..start();
await SVGAParser.shared.decodeFromURL('https://example.com/animation.svga');
print('First load: ${stopwatch.elapsedMilliseconds}ms');

stopwatch.reset();
await SVGAParser.shared.decodeFromURL('https://example.com/animation.svga');
print('Cached load: ${stopwatch.elapsedMilliseconds}ms'); // Should be much faster
```

### Monitor Cache Growth
```dart
// Periodically check cache statistics
Timer.periodic(Duration(minutes: 5), (timer) async {
  final stats = await SVGACache.shared.getStats();
  print('Cache: ${stats['fileCount']} files, ${stats['size'] ~/ 1024}KB');
});
```

## 🚨 Error Handling

The cache system is designed to fail gracefully:

- **Cache errors are silent**: If cache read/write fails, normal loading continues
- **No performance degradation**: Cache failures don't slow down the app
- **Self-healing**: Corrupted cache files are automatically removed

## 🔧 Troubleshooting

### Cache Not Working?
```dart
// Check if caching is enabled
print('Cache enabled: ${SVGACache.shared.isEnabled}');

// Check cache statistics
final stats = await SVGACache.shared.getStats();
print('Cache stats: $stats');
```

### Clear Cache During Development
```dart
// In debug builds, clear cache on app start
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    SVGACache.shared.clear(); // Clear during development
  }
  
  runApp(MyApp());
}
```

### Disable Caching Temporarily
```dart
// Disable for testing or troubleshooting
SVGACache.shared.setEnabled(false);

// Re-enable when done
SVGACache.shared.setEnabled(true);
```

## 🎨 Example Implementation

See `example/lib/cache_example.dart` for a complete working example showing:

- Cache configuration
- Real-time statistics monitoring  
- Cache management operations
- Performance comparisons

Run the example app and tap "Cache Example & Configuration" to explore all features interactively!