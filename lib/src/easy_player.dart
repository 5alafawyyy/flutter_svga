part of 'player.dart';

class SVGAEasyPlayer extends StatefulWidget {
  final String? resUrl;
  final String? assetsName;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final bool? allowDrawingOverflow;
  final bool clearsAfterStop;
  final Size? preferredSize;

  /// Audio volume level from `0.0` (silent) to `1.0` (full volume).
  ///
  /// Defaults to `1.0`.
  final double volume;

  /// Whether audio playback is muted.
  ///
  /// Defaults to `false`.
  final bool muted;

  /// Whether the animation should loop continuously.
  /// If `false`, the animation plays once via [SVGAAnimationController.forward].
  ///
  /// Defaults to `true`.
  final bool loops;

  /// Optional callback invoked after the SVGA [MovieEntity] is decoded,
  /// allowing dynamic elements (text, images, custom drawers, hidden layers)
  /// to be configured before playback starts.
  final void Function(MovieEntity entity)? dynamicCallback;

  /// Optional callback invoked when a non-looping animation (`loops: false`) completes.
  final VoidCallback? onFinished;

  const SVGAEasyPlayer({
    super.key,
    this.resUrl,
    this.assetsName,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.low,
    this.allowDrawingOverflow,
    this.clearsAfterStop = true,
    this.preferredSize,
    this.volume = 1.0,
    this.muted = false,
    this.loops = true,
    this.dynamicCallback,
    this.onFinished,
  });

  @override
  State<StatefulWidget> createState() {
    return _SVGAEasyPlayerState();
  }
}

class _SVGAEasyPlayerState extends State<SVGAEasyPlayer>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(
      vsync: this,
      volume: widget.volume,
      muted: widget.muted,
    );
    animationController!.addStatusListener(_handleStatusChange);
    _tryDecodeSvga();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinished?.call();
    }
  }

  @override
  void didUpdateWidget(covariant SVGAEasyPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume != widget.volume) {
      animationController?.volume = widget.volume;
    }
    if (oldWidget.muted != widget.muted) {
      animationController?.muted = widget.muted;
    }
    if (oldWidget.resUrl != widget.resUrl ||
        oldWidget.assetsName != widget.assetsName) {
      _tryDecodeSvga();
    } else if (oldWidget.loops != widget.loops &&
        animationController?.videoItem != null) {
      if (widget.loops) {
        animationController?.repeat();
      } else {
        animationController?.forward(from: animationController?.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return const SizedBox.shrink();
    }
    return SVGAImage(
      animationController!,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
      allowDrawingOverflow: widget.allowDrawingOverflow,
      clearsAfterStop: widget.clearsAfterStop,
      preferredSize: widget.preferredSize,
    );
  }

  @override
  void dispose() {
    animationController?.removeStatusListener(_handleStatusChange);
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  void _tryDecodeSvga() {
    Future<MovieEntity> decode;
    if (widget.resUrl != null) {
      decode = SVGAParser.shared.decodeFromURL(widget.resUrl!);
    } else if (widget.assetsName != null) {
      decode = SVGAParser.shared.decodeFromAssets(widget.assetsName!);
    } else {
      return;
    }

    decode
        .then((videoItem) {
          if (mounted && animationController != null) {
            if (widget.dynamicCallback != null) {
              widget.dynamicCallback!(videoItem);
            }
            animationController!
              ..volume = widget.volume
              ..muted = widget.muted
              ..videoItem = videoItem;
            if (widget.loops) {
              animationController!.repeat();
            } else {
              animationController!.forward();
            }
          } else {
            videoItem.dispose();
          }
        })
        .catchError((e, stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: e,
              stack: stack,
              library: 'SVGAEasyPlayer',
              context: ErrorDescription('during _tryDecodeSvga'),
              informationCollector: () => [
                if (widget.resUrl != null)
                  StringProperty('resUrl', widget.resUrl),
                if (widget.assetsName != null)
                  StringProperty('assetsName', widget.assetsName),
              ],
            ),
          );
        });
  }
}
