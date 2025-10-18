# flutter_svga

A **Flutter package** for parsing and rendering **SVGA animations** efficiently.  
SVGA is a lightweight and powerful animation format used for **dynamic UI effects** in mobile applications.

<p align="center">
  <img src="https://raw.githubusercontent.com/5alafawyyy/flutter_svga/master/example.gif" width="300"/>
  <img src="https://raw.githubusercontent.com/5alafawyyy/flutter_svga/master/example1.gif" width="300"/>
</p>

---

## 🚀 **Features**

✔️ Parse and render **SVGA animations** in Flutter.  
✔️ Load SVGA files from **assets** and **network URLs**.  
✔️ Supports **custom dynamic elements** (text, images, animations).  
✔️ **Optimized playback performance** with animation controllers.  
✔️ **Integrated audio playback** within SVGA animations.  
✔️ Works on **Android & iOS** (Web & Desktop support coming soon).  
✔️ Easy **loop, stop, and seek** functions.

---

## 📌 **Installation**

Add **flutter_svga** to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_svga: ^0.0.7
```
Then, install dependencies:

```sh
flutter pub get
```

---

## 🎬 **Basic Usage**

### ✅ **Playing an SVGA Animation from Assets**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter SVGA Example")),
        body: Center(
          child: SVGAEasyPlayer(
            assetsName: "assets/sample_with_audio.svga",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

---

## 🌍 **Playing SVGA from a Network URL**
```dart
SVGAEasyPlayer(
  resUrl: "https://example.com/sample.svga",
  fit: BoxFit.cover,
);
```

---

## 🎭 **Advanced Usage: Using SVGAAnimationController**

### ✅ **Controlling Animation Playback**
```dart
class MySVGAWidget extends StatefulWidget {
  @override
  _MySVGAWidgetState createState() => _MySVGAWidgetState();
}

class _MySVGAWidgetState extends State<MySVGAWidget>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    SVGAParser.shared.decodeFromAssets("assets/sample.svga").then((video) {
      _controller.videoItem = video;
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SVGAImage(_controller);
  }
}
```

---

## 🎨 **Customization & Dynamic Elements**

### ✅ **Adding Dynamic Text**
```dart
controller.videoItem!.dynamicItem.setText(
  TextPainter(
    text: TextSpan(
      text: "Hello SVGA!",
      style: TextStyle(color: Colors.red, fontSize: 18),
    ),
    textDirection: TextDirection.ltr,
  ),
  "text_layer",
);
```

---

### ✅ **Replacing an Image Dynamically**
```dart
controller.videoItem!.dynamicItem.setImageWithUrl(
  "https://example.com/new_image.png",
  "image_layer",
);
```

---

### ✅ **Hiding a Layer**
```dart
controller.videoItem!.dynamicItem.setHidden(true, "layer_to_hide");
```

---

## 🎯 **Playback Controls**
```dart
controller.forward();  // Play once
controller.repeat();   // Loop playback
controller.stop();     // Stop animation
controller.value = 0;  // Reset to first frame
```

---

## 🛠 **Common Issues & Solutions**

### ❌ **Black Screen when Loading SVGA**
✅ **Solution:** Ensure your `svga` files are correctly placed inside `assets/` and registered in `pubspec.yaml`.
```yaml
flutter:
  assets:
    - assets/sample.svga
```

---

### ❌ **SVGA Not Loading from Network**
✅ **Solution:** Ensure the SVGA file is accessible via HTTPS. Test the URL in a browser.
```dart
SVGAEasyPlayer(
  resUrl: "https://example.com/sample.svga",
  fit: BoxFit.cover,
);
```

---

### ❌ **Animation Freezes or Doesn't Play**
✅ **Solution:** Use `setState` after loading SVGA to rebuild the widget.
```dart
setState(() {
  _controller.videoItem = video;
});
```

---

## 📱 **Supported Platforms**

| Platform | Supported | Audio Support |
|----------|-----------|---------------|
| ✅ Android | ✔️ Yes | ✔️ Yes |
| ✅ iOS | ✔️ Yes | ✔️ Yes |
| ✅ Linux | ✔️ Yes | ✔️ Yes |
| ✅ Web | ✔️ Yes | ❌ No |
| ✅ macOS | ✔️ Yes | ✔️ Yes |
| ✅ Desktop | ✔️ Yes | ✔️ Yes |

---

## 🔄 **Changelog**
See the latest changes in [`CHANGELOG.md`](CHANGELOG.md).

---

## 📜 **License**
This package is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

---

## 🤝 **Contributing**
- If you find a **bug**, report it [here](https://github.com/5alafawyyy/flutter_svga/issues).
- Pull requests are welcome! See [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidelines.

---

🚀 **Enjoy using SVGA animations in your Flutter app!** 🚀

