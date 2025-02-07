import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network("https://${widget.videoUrl}");
    
    try {
      await _controller.initialize();
      // Auto-play when initialized
      _controller.play();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
      // Handle error appropriately
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Show thumbnail while loading
          if (!_isInitialized)
            Center(
              child: CachedNetworkImage(
                imageUrl: widget.thumbnailUrl,
                fit: BoxFit.contain,
              ),
            ),
          // Video player
          if (_isInitialized)
            GestureDetector(
              onTap: _toggleControls,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          // Loading indicator
          if (!_isInitialized)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          // Buffering indicator
          if (_isInitialized)
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                if (value.isBuffering) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          // Video controls overlay
          if (_isInitialized && _showControls)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: Stack(
                  children: [
                    // Play/Pause button in center
                    Center(
                      child: ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, VideoPlayerValue value, child) {
                          return IconButton(
                            iconSize: 64,
                            icon: Icon(
                              value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              value.isPlaying ? _controller.pause() : _controller.play();
                            },
                          );
                        },
                      ),
                    ),
                    // Bottom controls bar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar
                            ValueListenableBuilder(
                              valueListenable: _controller,
                              builder: (context, VideoPlayerValue value, child) {
                                return SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor: Colors.white30,
                                    thumbColor: Colors.red,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                                  ),
                                  child: Slider(
                                    value: value.position.inMilliseconds.toDouble(),
                                    min: 0,
                                    max: value.duration.inMilliseconds.toDouble(),
                                    onChanged: (position) {
                                      _controller.seekTo(Duration(milliseconds: position.toInt()));
                                    },
                                  ),
                                );
                              },
                            ),
                            // Time indicators
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ValueListenableBuilder(
                                valueListenable: _controller,
                                builder: (context, VideoPlayerValue value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(value.position),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        _formatDuration(value.duration),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}