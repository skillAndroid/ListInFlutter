import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to fetch and then display video content.
/// ignore: must_be_immutable
class MultiVideoItem extends StatefulWidget {
  dynamic videoSource;
  int index;
  Function(VideoPlayerController controller) onInit;
  Function(int index) onDispose;
  VideoPlayerOptions? videoPlayerOptions;
  VideoSource sourceType;
  Future<ClosedCaptionFile>? closedCaptionFile;
  Map<String, String>? httpHeaders;
  VideoFormat? formatHint;
  String? package;
  bool showControlsOverlay;
  bool showVideoProgressIndicator;
  bool show = true;

  MultiVideoItem({
    super.key,
    required this.videoSource,
    required this.index,
    required this.onInit,
    required this.onDispose,
    this.videoPlayerOptions,
    this.closedCaptionFile,
    this.httpHeaders,
    this.formatHint,
    this.package,
    this.showControlsOverlay = true,
    this.showVideoProgressIndicator = true,
    required this.sourceType,
  });

  @override
  State<MultiVideoItem> createState() => _MultiVideoItemState();
}

class _MultiVideoItemState extends State<MultiVideoItem> {
  late VideoPlayerController _controller;
  bool isLoading = true;
  bool _isDisposed = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// initializes videos
  void _initializeVideo() async {
    try {
      _playbackTimer?.cancel();
      // ignore: deprecated_member_use
      _controller = VideoPlayerController.network(
        widget.videoSource,
        videoPlayerOptions: widget.videoPlayerOptions,
        closedCaptionFile: widget.closedCaptionFile,
        httpHeaders: widget.httpHeaders ?? {},
        formatHint: widget.formatHint,
      );

      _controller.addListener(_videoListener);

      await _controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Video initialization timeout: ${widget.videoSource}');
          throw TimeoutException('Video initialization timeout');
        },
      );

      if (_isDisposed) {
        await _cleanupResources();
        return;
      }

      widget.onInit.call(_controller);

      if (widget.index == MultiVideo.currentIndex) {
        _playbackTimer = Timer(const Duration(milliseconds: 300), () {
          if (!_isDisposed && mounted) {
            _controller.play();
          }
        });
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      await _cleanupResources();
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _cleanupResources() async {
    _playbackTimer?.cancel();
    if (_controller.value.isInitialized) {
      await _controller.pause();
    }
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.value.isInitialized
              ? _buildVideoPlayer()
              : const SizedBox.shrink(),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            if (widget.showControlsOverlay)
              _ControlsOverlay(
                controller: _controller,
              ),
            if (widget.showVideoProgressIndicator)
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.all(8.0),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playbackTimer?.cancel();
    _controller.removeListener(_videoListener);
    _cleanupResources();
    widget.onDispose.call(widget.index);
    super.dispose();
  }

  void _videoListener() {
    if (_isDisposed || !mounted) return;

    // Handle playback errors
    if (_controller.value.hasError) {
      debugPrint('Video playback error: ${_controller.value.errorDescription}');
      _cleanupResources();
      return;
    }

    // Manage playback based on visibility
    if (widget.index != MultiVideo.currentIndex) {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            });
          },
        ),
      ],
    );
  }
}
