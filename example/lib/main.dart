import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

import 'cache_example.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(), theme: ThemeData(useMaterial3: false));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? svgaUrl;

  final samples = const <String>[
    "assets/angel.svga",
    "assets/pin_jump.svga",
    "assets/audio_biling.svga",
    "assets/lion.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/EmptyState.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/HamburgerArrow.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/PinJump.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/TwitterHeart.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/Walkthrough.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/kingset.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/halloween.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/heartbeat.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteBitmap.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteBitmap_1.x.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteRect.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/mutiMatte.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/posche.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/rose.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/Rocket.svga",
  ].map((e) => [e.split('/').last, e]).toList(growable: false);

  /// Navigate to the [SVGASampleScreen] showing the animation at the given
  /// [sample] URL.
  ///
  /// The [sample] is a list of 2 elements, where the first is the display name
  /// of the sample, and the second is the URL of the animation.
  ///
  /// The [dynamicCallback] parameter of [SVGASampleScreen] is set to the value
  /// in [dynamicSamples] for the given [sample] name, or null if there is no
  /// entry in that map.
  void _goToSample(BuildContext context, List<String> sample) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SVGASampleScreen(name: sample.first, image: sample.last, dynamicCallback: dynamicSamples[sample.first]),
      ),
    );
  }

  /// Navigate to the [SVGASampleScreen] showing the animation at the given
  /// [imageUrl].
  ///
  /// This function is used by the "Load SVGA from text field" button in the
  /// [MyApp] widget, to load an animation from a URL entered in the text field.
  void _goToSampleFromInput(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SVGASampleScreen(image: imageUrl)));
  }

  /// Load the animation from the URL in the text field, and navigate to
  /// [SVGASampleScreen] to display it.
  ///
  /// This function is called when the user presses the "Load SVGA from text
  /// field" button in [MyApp].
  ///
  /// The [svgaUrl] member is updated with the text of the text field, and then
  /// [SVGASampleScreen] is pushed onto the navigator stack with the value of
  /// [svgaUrl] as the URL of the animation to display.
  ///
  /// This function does nothing if the text field is empty.
  void _loadSvgaFromTextField() {
    if (_urlController.text.isNotEmpty) {
      setState(() {
        svgaUrl = _urlController.text;
      });
      _goToSampleFromInput(context, _urlController.text);
    }
  }

  final dynamicSamples = <String, void Function(MovieEntity entity)>{
    "kingset.svga": (entity) => entity.dynamicItem
      ..setText(
        TextPainter(
          text: TextSpan(
            text: "Hello, World!",
            style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        "banner",
      )
      ..setImageWithUrl("https://github.com/PonyCui/resources/blob/master/svga_replace_avatar.png?raw=true", "99")
      ..setDynamicDrawer((canvas, frameIndex) {
        canvas.drawRect(Rect.fromLTWH(0, 0, 88, 88), Paint()..color = Colors.red); // draw by yourself.
      }, "banner"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SVGA Flutter Samples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field for SVGA URL
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter SVGA URL",
                hintText: "Paste an SVGA file URL...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.blue),
                  onPressed: _loadSvgaFromTextField,
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _loadSvgaFromTextField(),
            ),
            SizedBox(height: 16),

            // Cache Example Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SVGACacheExample()));
                },
                icon: Icon(Icons.storage),
                label: Text('Cache Example & Configuration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: samples.length,
                separatorBuilder: (_, _) => Divider(color: Colors.grey, thickness: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.animation, color: Colors.white),
                    ),
                    title: Text(samples[index].first, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(samples[index].last, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    trailing: Icon(Icons.play_circle_fill_outlined, color: Colors.blue),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () => _goToSample(context, samples[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SVGASampleScreen extends StatefulWidget {
  final String? name;
  final String image;
  final void Function(MovieEntity entity)? dynamicCallback;

  const SVGASampleScreen({super.key, required this.image, this.name, this.dynamicCallback});

  @override
  State<SVGASampleScreen> createState() => _SVGASampleScreenState();
}

class _SVGASampleScreenState extends State<SVGASampleScreen> with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;
  bool isLoading = true;
  Color backgroundColor = Colors.transparent;
  bool allowOverflow = true;
  FilterQuality filterQuality = kIsWeb ? FilterQuality.high : FilterQuality.low;
  BoxFit fit = BoxFit.contain;
  late double containerWidth;
  late double containerHeight;
  bool hideOptions = true;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerWidth = math.min(350, MediaQuery.of(context).size.width);
    containerHeight = math.min(350, MediaQuery.of(context).size.height);
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  void _loadAnimation() async {
    final videoItem = await _loadVideoItem(widget.image);
    if (widget.dynamicCallback != null) {
      widget.dynamicCallback!(videoItem);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        animationController?.videoItem = videoItem;
        _playAnimation();
      });
    }
  }

  void _playAnimation() {
    if (animationController?.isCompleted == true) {
      animationController?.reset();
    }
    animationController?.repeat(); // or animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name ?? "")),
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text("Url: ${widget.image}", style: Theme.of(context).textTheme.headlineSmall),
          ),
          if (isLoading) LinearProgressIndicator(),
          Center(
            child: ColoredBox(
              color: backgroundColor,
              child: SVGAImage(
                animationController!,
                fit: fit,
                clearsAfterStop: false,
                allowDrawingOverflow: allowOverflow,
                filterQuality: filterQuality,
                preferredSize: Size(containerWidth, containerHeight),
              ),
            ),
          ),
          Positioned(bottom: 10, child: _buildOptions(context)),
        ],
      ),
      floatingActionButton: isLoading || animationController!.videoItem == null
          ? null
          : FloatingActionButton.extended(
              label: Text(animationController!.isAnimating ? "Pause" : "Play"),
              icon: Icon(animationController!.isAnimating ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (animationController?.isAnimating == true) {
                  animationController?.stop();
                } else {
                  _playAnimation();
                }
                setState(() {});
              },
            ),
    );
  }

  /// Builds the options panel for the sample.
  ///
  /// This includes a toggle button to show/hide the options, a current frame indicator,
  /// a frame slider, an image filter quality dropdown, an allow drawing overflow switch,
  /// width/height sliders, a box fit dropdown, and a background color picker.
  ///
  /// The returned widget is a [Column] with the specified children, wrapped in an
  /// [AnimatedContainer] to animate the height and opacity of the options panel.
  ///
  /// The [hideOptions] parameter is used to control whether the options panel is shown
  /// or hidden. If [hideOptions] is true, the panel is hidden and the toggle button is
  /// labeled "Show Options". If [hideOptions] is false, the panel is shown and the
  /// toggle button is labeled "Hide Options".
  ///
  /// The [animationController] parameter is used to control the animation of the
  /// frame slider. If [animationController] is null, the frame slider is disabled.
  ///
  /// The [context] parameter is used to access the [Theme] of the app and the
  /// [MediaQuery] to get the screen size.
  ///
  /// Returns a [Widget] that displays the options panel.
  Widget _buildOptions(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 240,
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Button
          ListTile(
            leading: Icon(hideOptions ? Icons.expand_more : Icons.expand_less, color: Colors.blue),
            title: Text(hideOptions ? "Show Options" : "Hide Options", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              setState(() {
                hideOptions = !hideOptions;
              });
            },
          ),

          if (!hideOptions) ...[
            Divider(),

            // Current Frame Indicator
            AnimatedBuilder(
              animation: animationController!,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Current Frame: ${animationController!.currentFrame + 1}/${animationController!.frames}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),

            // Frame Slider
            AnimatedBuilder(
              animation: animationController!,
              builder: (context, child) {
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.blue[100],
                    thumbColor: Colors.blueAccent,
                  ),
                  child: Slider(
                    min: 0,
                    max: animationController!.frames.toDouble(),
                    value: animationController!.currentFrame.toDouble(),
                    label: '${animationController!.currentFrame}',
                    onChanged: (v) {
                      if (animationController?.isAnimating == true) {
                        animationController?.stop();
                      }
                      animationController?.value = v / animationController!.frames;
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 8),

            // Image Filter Quality
            _buildDropdown(
              label: "Image Filter Quality",
              value: filterQuality,
              items: FilterQuality.values,
              onChanged: (newValue) {
                setState(() {
                  filterQuality = newValue!;
                });
              },
            ),

            // Allow Drawing Overflow Switch
            _buildSwitch("Allow Drawing Overflow", allowOverflow, (v) {
              setState(() {
                allowOverflow = v;
              });
            }),

            Divider(),

            // Width & Height Sliders
            _buildSlider(
              context,
              label: "Width",
              value: containerWidth,
              min: 100,
              max: MediaQuery.of(context).size.width,
              onChanged: (v) {
                setState(() {
                  containerWidth = v.truncateToDouble();
                });
              },
            ),
            _buildSlider(
              context,
              label: "Height",
              value: containerHeight,
              min: 100,
              max: MediaQuery.of(context).size.height,
              onChanged: (v) {
                setState(() {
                  containerHeight = v.truncateToDouble();
                });
              },
            ),

            // BoxFit Dropdown
            _buildDropdown(
              label: "Box Fit",
              value: fit,
              items: BoxFit.values,
              onChanged: (newValue) {
                setState(() {
                  fit = newValue!;
                });
              },
            ),

            SizedBox(height: 8),

            // Background Color Picker
            _buildColorPicker(),
          ],
        ],
      ),
    );
  }

  /// A styled dropdown widget for selecting a value from a list of items.
  ///
  /// [label] is the label displayed before the dropdown.
  ///
  /// [value] is the currently selected value.
  ///
  /// [items] is the list of items to display in the dropdown.
  ///
  /// [onChanged] is the callback to call when the user selects a new item.
  ///
  /// The items are displayed as [DropdownMenuItem]s, with the `value` of each
  /// item being the item itself, and the `child` being a [Text] displaying the
  /// last part of the item's `toString()` split by '.'.
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<T>(
            value: value,
            onChanged: onChanged,
            items: items.map((T item) {
              return DropdownMenuItem(value: item, child: Text(item.toString().split('.').last));
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// A styled switch widget for toggling a boolean value.
  ///
  /// [label] is the label displayed before the switch.
  ///
  /// [value] is the currently selected value.
  ///
  /// [onChanged] is the callback to call when the user toggles the switch.
  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSlider(
    /// A styled slider widget for selecting a value between [min] and [max].
    ///
    /// [label] is the label displayed above the slider.
    ///
    /// [value] is the currently selected value.
    ///
    /// [onChanged] is the callback to call when the user changes the value.
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          min: min,
          max: max,
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    /// A widget that displays a list of colors and allows the user to select one.
    ///
    /// The selected color is used as the background color for the [SVGAEasyPlayer].
    ///
    /// When the user taps on a color, the corresponding color is saved to the
    /// [backgroundColor] state variable.
    ///
    /// The colors are displayed in a row, with the selected color highlighted with a
    /// white border.
    List<Color> colors = [Colors.transparent, Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.black];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Background Color"),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: colors
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        backgroundColor = color;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: backgroundColor == color ? Colors.white : Colors.grey, width: 3),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Loads a video item from a given image source URL or asset path.
///
/// Determines whether the image source is a URL or a local asset path,
/// then uses the appropriate decoder function from `SVGAParser` to load
/// and return the video item as a `Future`.
///
/// [image] is the source of the video item, which can be an HTTP/HTTPS URL
/// or a local asset path.

Future _loadVideoItem(String image) {
  Future Function(String) decoder;
  if (image.startsWith(RegExp(r'https?://'))) {
    decoder = SVGAParser.shared.decodeFromURL;
  } else {
    decoder = SVGAParser.shared.decodeFromAssets;
  }
  return decoder(image);
}
