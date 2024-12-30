// ignore_for_file: deprecated_member_use, empty_catches

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LazyVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool autoplay;

  const LazyVideoPlayer({
    required this.videoUrl,
    required this.thumbnailUrl,
    this.autoplay = false,
    super.key,
  });

  @override
  State<LazyVideoPlayer> createState() => _LazyVideoPlayerState();
}

class _LazyVideoPlayerState extends State<LazyVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (_initialized) return;

    _controller = VideoPlayerController.network(widget.videoUrl);
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        if (widget.autoplay) _controller!.play();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
