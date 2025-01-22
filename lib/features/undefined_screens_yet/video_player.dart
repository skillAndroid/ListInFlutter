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
  late VideoPlayerController _controller;
  late ValueNotifier<bool> _isInitialized;
  late ValueNotifier<bool> _isBuffering;
  late ValueNotifier<bool> _isMuted;
  late ValueNotifier<bool> _showControls;
  late ValueNotifier<Duration> _position;
  late ValueNotifier<Duration> _duration;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
    _initializeVideo();
  }

  void _initializeNotifiers() {
    _isInitialized = ValueNotifier(false);
    _isBuffering = ValueNotifier(true);
    _isMuted = ValueNotifier(false);
    _showControls = ValueNotifier(true);
    _position = ValueNotifier(Duration.zero);
    _duration = ValueNotifier(Duration.zero);
  }

  Future<void> _initializeVideo() async {
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);
      
      if (mounted) {
        _isInitialized.value = true;
        _isBuffering.value = false;
        _duration.value = _controller.value.duration;
        if (widget.isPlaying) _controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;
    
    _isBuffering.value = _controller.value.isBuffering;
    _position.value = _controller.value.position;
    
    // Update duration if it changes (rare, but possible with adaptive streaming)
    if (_duration.value != _controller.value.duration) {
      _duration.value = _controller.value.duration;
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _showControls.value = false;
      }
    });
  }

  void _handleVideoTap() {
    _showControls.value = !_showControls.value;
    if (_showControls.value) _startHideControlsTimer();
  }

  void _handleVolumeToggle() {
    _isMuted.value = !_isMuted.value;
    _controller.setVolume(_isMuted.value ? 0 : 1);
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized.value) {
      widget.isPlaying ? _controller.play() : _controller.pause();
    }
    
    if (widget.videoUrl != oldWidget.videoUrl) {
      _isInitialized.value = false;
      _controller.dispose();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _isInitialized.dispose();
    _isBuffering.dispose();
    _isMuted.dispose();
    _showControls.dispose();
    _position.dispose();
    _duration.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Duration _getRemainingTime() {
    return _duration.value - _position.value;
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _position,
      builder: (context, position, _) {
        return SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.containerColor,
            thumbColor: AppColors.primaryLight,
            trackShape: const _CustomTrackShape(),
            thumbShape: const RectangularSliderThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble(),
            min: 0,
            max: _duration.value.inMilliseconds.toDouble(),
            onChanged: (value) {
              _controller.seekTo(Duration(milliseconds: value.toInt()));
            },
            onChangeEnd: (value) {
              if (widget.isPlaying) _controller.play();
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _position,
      builder: (context, _, __) {
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
      },
    );
  }

  Widget _buildVolumeButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isMuted,
      builder: (context, isMuted, _) {
        return IconButton(
          icon: Icon(
            isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_up,
            color: Colors.white,
            size: 28,
          ),
          onPressed: _handleVolumeToggle,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitialized,
      builder: (context, isInitialized, _) {
        if (!isInitialized) {
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

        return GestureDetector(
          onTap: _handleVideoTap,
          child: Stack(
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
              ValueListenableBuilder<bool>(
                valueListenable: _showControls,
                builder: (context, showControls, _) {
                  if (!showControls) return const SizedBox.shrink();
                  
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildProgressBar(),
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
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isBuffering,
                builder: (context, isBuffering, _) {
                  if (!isBuffering) return const SizedBox.shrink();
                  
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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