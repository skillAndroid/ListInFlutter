// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const VideoPlayerWidget({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    super.key,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = true;
  bool _isMuted = false;
  bool _showControls = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await _controller?.initialize();
      _controller?.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
          _duration = _controller?.value.duration ?? Duration.zero;
        });
        if (widget.isPlaying) _controller?.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _isBuffering = _controller?.value.isBuffering ?? false;
      _position = _controller?.value.position ?? Duration.zero;

      if (_duration != _controller?.value.duration) {
        _duration = _controller?.value.duration ?? Duration.zero;
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _handleVideoTap() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideControlsTimer();
    });
  }

  void _handleVolumeToggle() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized) {
      widget.isPlaying ? _controller?.play() : _controller?.pause();
    }

    if (widget.videoUrl != oldWidget.videoUrl) {
      setState(() {
        _isInitialized = false;
      });
      _controller?.dispose();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Duration _getRemainingTime() {
    return _duration - _position;
  }

  Widget _buildProgressBar() {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: Colors.grey,
        inactiveTrackColor: AppColors.containerColor,
        thumbColor: AppColors.primaryLight,
        trackShape: const _CustomTrackShape(),
        thumbShape: const RectangularSliderThumbShape(),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        value: _position.inMilliseconds.toDouble(),
        min: 0,
        max: _duration.inMilliseconds.toDouble(),
        onChanged: (value) {
          _controller?.seekTo(Duration(milliseconds: value.toInt()));
        },
        onChangeEnd: (value) {
          if (widget.isPlaying) _controller?.play();
        },
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return SmoothClipRRect(
      smoothness: 1,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          _formatDuration(_getRemainingTime()),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeButton() {
    return IconButton(
      icon: Icon(
        _isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_up,
        color: Colors.white,
        size: 28,
      ),
      onPressed: _handleVolumeToggle,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error),
        ),
      );
    }

    return GestureDetector(
      onTap: _handleVideoTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller?.value.size.width ?? 0,
                height: _controller?.value.size.height ?? 0,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          if (_showControls)
            Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.translate(
                      offset: Offset(0, 3), child: _buildProgressBar()),
                ),
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: _buildTimeDisplay(),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildVolumeButton(),
                ),
              ],
            ),
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomTrackShape extends RectangularSliderTrackShape {
  const _CustomTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class RectangularSliderThumbShape extends SliderComponentShape {
  final double radius;

  const RectangularSliderThumbShape({this.radius = 4.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: sliderTheme.trackHeight!,
      ),
      paint,
    );
  }
}

class SimpleVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;

  const SimpleVideoPlayerWidget({
    required this.videoUrl,
    required this.thumbnailUrl,
    super.key,
  });

  @override
  State<SimpleVideoPlayerWidget> createState() =>
      _SimpleVideoPlayerWidgetState();
}

class _SimpleVideoPlayerWidgetState extends State<SimpleVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(
      widget.videoUrl,
    );

    try {
      await _controller?.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller?.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void didUpdateWidget(SimpleVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoUrl != oldWidget.videoUrl) {
      setState(() {
        _isInitialized = false;
      });
      _controller?.dispose();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Stack(
        children: [
          SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: widget.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller?.value.size.width ?? 0,
          height: _controller?.value.size.height ?? 0,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
