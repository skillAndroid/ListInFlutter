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
  final Function onPlay;
  final Function onPause;

  const VideoPlayerWidget({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    super.key,
  });

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
          if (widget.isPlaying) {
            _controller.play();
          }
        });
        _controller.addListener(_videoListener);
      });
  }

  void _videoListener() {
    setState(() {
      _isBuffering = _controller.value.isBuffering;
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
    if (widget.videoUrl != oldWidget.videoUrl) {
      _isInitialized = false;
      _controller.dispose();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildProgressBar() {
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return Stack(
      alignment: Alignment.center,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: AppColors.green,
            inactiveTrackColor: AppColors.containerColor,
            thumbColor: AppColors.primary,
            // Custom rectangle shape for track
            trackShape: const RectangularSliderTrackShape(),
            // Custom rectangle shape for thumb
            thumbShape: const RectangularSliderThumbShape(
              enabledThumbRadius: 0,
              disabledThumbRadius: 0,
            ),
            // Remove overlay completely
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble(),
            min: 0,
            max: duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              setState(() {
                _controller.seekTo(Duration(milliseconds: value.toInt()));
              });
            },
            onChangeEnd: (value) {
              setState(() {
                if (widget.isPlaying) {
                  _controller.play();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildProgressBar(),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: SmoothClipRRect(
            smoothness: 1,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              // ignore: deprecated_member_use
              color: AppColors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  _formatDuration(_controller.value.position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isBuffering)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              _isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_mute,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
                _controller.setVolume(_isMuted ? 0 : 1);
              });
            },
          ),
        ),
      ],
    );
  }
}
// Custom rectangular thumb shape
class RectangularSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double disabledThumbRadius;

  const RectangularSliderThumbShape({
    this.enabledThumbRadius = 4.0,
    this.disabledThumbRadius = 4.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? enabledThumbRadius : disabledThumbRadius);
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

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: center,
      width: enabledThumbRadius * 2,
      height: sliderTheme.trackHeight!,
    );

    canvas.drawRect(rect, paint);
  }
}