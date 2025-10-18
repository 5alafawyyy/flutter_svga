import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

/// Example showing how to use SVGA caching features
class SVGACacheExample extends StatefulWidget {
  const SVGACacheExample({super.key});

  @override
  State<SVGACacheExample> createState() => _SVGACacheExampleState();
}

class _SVGACacheExampleState extends State<SVGACacheExample> {
  Map<String, dynamic> _cacheStats = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _configureCache();
    _refreshCacheStats();
  }

  /// Configure cache settings (optional - has sensible defaults)
  void _configureCache() {
    // Enable/disable caching (enabled by default)
    SVGACache.shared.setEnabled(true);

    // Set maximum cache size (default: 100MB)
    SVGACache.shared.setMaxCacheSize(50 * 1024 * 1024); // 50MB

    // Set maximum age for cached files (default: 7 days)
    SVGACache.shared.setMaxAge(const Duration(days: 3)); // 3 days
  }

  /// Refresh cache statistics
  Future<void> _refreshCacheStats() async {
    final stats = await SVGACache.shared.getStats();
    setState(() {
      _cacheStats = stats;
    });
  }

  /// Load an SVGA animation (automatically uses cache)
  Future<void> _loadAnimation() async {
    setState(() {
      _loading = true;
    });

    try {
      // This will automatically check cache first, then load from network if needed
      final movieEntity = await SVGAParser.shared.decodeFromURL(
        'https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/EmptyState.svga',
      );

      // Use the animation as normal
      debugPrint('Animation loaded: ${movieEntity.version}');

      // Refresh stats to see cache changes
      await _refreshCacheStats();
    } catch (e) {
      debugPrint('Error loading animation: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Clear specific item from cache
  Future<void> _clearSpecificCache() async {
    await SVGACache.shared.remove(
      'https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/EmptyState.svga',
    );
    await _refreshCacheStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Specific cache item cleared')),
    );
  }

  /// Clear all cache
  Future<void> _clearAllCache() async {
    await SVGACache.shared.clear();
    await _refreshCacheStats();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All cache cleared')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVGA Cache Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cache Configuration Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cache Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cache is ${SVGACache.shared.isEnabled ? 'enabled' : 'disabled'}',
                      ),
                      Text(
                        'Max cache size: ${SVGACache.shared.maxCacheSize ~/ (1024 * 1024)}MB',
                      ),
                      Text('Max age: ${SVGACache.shared.maxAge.inDays} days'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cache Statistics Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Cache Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _refreshCacheStats,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Enabled: ${_cacheStats['enabled'] ?? 'Unknown'}'),
                      Text('File count: ${_cacheStats['fileCount'] ?? 0}'),
                      Text(
                        'Cache size: ${(_cacheStats['size'] ?? 0) ~/ 1024}KB',
                      ),
                      Text(
                        'Max size: ${(_cacheStats['maxSize'] ?? 0) ~/ (1024 * 1024)}MB',
                      ),
                      Text('Max age: ${_cacheStats['maxAge'] ?? 0} days'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Actions Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cache Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _loadAnimation,
                          child: _loading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading...'),
                                  ],
                                )
                              : const Text('Load Animation (Uses Cache)'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _clearSpecificCache,
                          child: const Text('Clear Specific Cache Item'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _clearAllCache,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear All Cache'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Usage Notes
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Caching is enabled by default'),
                      Text(
                        '• Cache works automatically with existing SVGAParser methods',
                      ),
                      Text('• No breaking changes to existing code'),
                      Text('• Cache is persistent across app restarts'),
                      Text(
                        '• Cache automatically handles expiration and size limits',
                      ),
                      Text('• Both network URLs and assets are cached'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
