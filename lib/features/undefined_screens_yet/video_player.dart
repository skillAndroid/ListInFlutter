import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl; // Add thumbnail URL parameter
  final bool isPlaying;
  final Function onPlay;
  final Function onPause;

  const VideoPlayerWidget({
    required this.videoUrl,
    required this.thumbnailUrl, // Add required thumbnail parameter
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

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
          // Auto-play if isPlaying is true when initialization completes
          if (widget.isPlaying) {
            _controller.play();
          }
        });
      });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle changes in isPlaying state
    if (widget.isPlaying != oldWidget.isPlaying && _isInitialized) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }

    // Reinitialize if video URL changes
    if (widget.videoUrl != oldWidget.videoUrl) {
      _isInitialized = false;
      _controller.dispose();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show thumbnail while video is loading
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
      onTap: () {
        if (_controller.value.isPlaying) {
          widget.onPause();
        } else {
          widget.onPlay();
        }
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
