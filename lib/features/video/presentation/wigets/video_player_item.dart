import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_in/features/video/presentation/wigets/preloaded_video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;
  final double bufferingProgress;
  final VideoState videoState;

  const VideoPlayerItem({
    super.key,
    required this.controller,
    required this.title,
    required this.bufferingProgress,
    required this.videoState,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  bool _isPlaying = false;
  bool _isBuffering = false;
  Timer? _bufferingTimer;
  
  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _bufferingTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

    @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
      
      // Ensure proper state on controller switch
      _isPlaying = widget.controller.value.isPlaying;
      _isBuffering = widget.controller.value.isBuffering;
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    // Handle playing state
    final playing = widget.controller.value.isPlaying;
    if (playing != _isPlaying) {
      setState(() => _isPlaying = playing);
    }

    // Handle buffering state with debounce
    if (widget.controller.value.isBuffering) {
      _bufferingTimer?.cancel();
      
      // Only show buffering indicator if it persists for more than 300ms
      _bufferingTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted && widget.controller.value.isBuffering) {
          setState(() => _isBuffering = true);
        }
      });
    } else {
      _bufferingTimer?.cancel();
      if (_isBuffering) {
        setState(() => _isBuffering = false);
      }
    }
  }

  Widget _buildVideoOverlay() {
    if (!widget.controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber,));
    }

    // Show loading indicator only if:
    // 1. Video is buffering (with debounce)
    // 2. Video is not playing
    // 3. Not in error state
    final showLoading = _isBuffering && 
                       !_isPlaying && 
                       widget.videoState != VideoState.error;

    return AnimatedOpacity(
      opacity: showLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        VideoPlayer(widget.controller),

        // Loading overlay with animation
        _buildVideoOverlay(),

        // Video title
        Positioned(
          left: 16,
          bottom: 16,
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        // Optional: Add tap to play/pause
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (_isPlaying) {
                widget.controller.pause();
              } else {
                widget.controller.play();
              }
            },
          ),
        ),
      ],
    );
  }
}