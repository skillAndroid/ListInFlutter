import 'package:cached_network_image/cached_network_image.dart';
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
  bool _isDragging = false;
  bool _isMuted = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
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
    final buffered = _controller.value.buffered;

    // Calculate buffered progress as a percentage of the total duration
    double getBufferedPosition() {
      if (buffered.isNotEmpty) {
        return buffered.last.end.inMilliseconds.toDouble();
      }
      return 0.0;
    }

    return Stack(
      children: [
        // Buffered progress
        Positioned.fill(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor:
                  Colors.green.shade700, // Color for buffered progress
              inactiveTrackColor: Colors.transparent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            ),
            child: Slider(
              value: getBufferedPosition(),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              onChanged: null, // Buffered slider is non-interactive
            ),
          ),
        ),
        // Current progress
        Positioned.fill(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: AppColors.green, // Color for current progress
              inactiveTrackColor: AppColors.containerColor,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 0,
              ),
            ),
            child: Slider(
              value: position.inMilliseconds.toDouble(),
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _controller.seekTo(Duration(milliseconds: value.toInt()));
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  _isDragging = false;
                  if (widget.isPlaying) {
                    _controller.play();
                  }
                });
              },
            ),
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
          bottom: 16, // Adjusted to be just above the slider
          right: 16,
          child: SmoothClipRRect(
            smoothness: 1,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              // ignore: deprecated_member_use
              color: AppColors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  _formatDuration(_controller.value.position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 24,
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
