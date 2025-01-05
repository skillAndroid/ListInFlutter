// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:list_in/features/video/data/models/video_model.dart';
import 'package:list_in/features/video/presentation/wigets/preloaded_video_controller.dart';
import 'package:list_in/features/video/presentation/wigets/video_player_item.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final List<Video> videos = [
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      title: 'Big Buck Bunny',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      title: 'Elephants Dream',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      title: 'For Bigger Blazes',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      title: 'For Bigger Escapes',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      title: 'For Bigger Fun',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      title: 'For Bigger Joyrides',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      title: 'Subaru Outback On Street And Dirt',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      title: 'Tears of Steel',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      title: 'We Are Going On Bullrun',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg',
    ),
    Video(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
      title: 'What car can you get for a grand?',
      thumbnailUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/images/WhatCarCanYouGetForAGrand.jpg',
    ),
  ];

  final PreloadedVideoController _preloadedController =
      PreloadedVideoController();
  late PageController _pageController;
  bool _isInitializing = true;
  final Map<int, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeFirstVideo();
  }

  Future<void> _initializeFirstVideo() async {
    try {
      _loadingStates[0] = true;

      await _preloadedController.preloadVideo(0, videos[0].url);

      if (mounted) {
        setState(() {
          _loadingStates[0] = false;
          _isInitializing = false;
        });

        await _preloadedController
            .playVideo(0); // Play the video immediately after preloading

        if (videos.length > 1) {
          _preloadedController.preloadVideo(1, videos[1].url);
        }
      }
    } catch (e) {
      debugPrint('Error initializing first video: $e');
      if (mounted) {
        setState(() {
          _loadingStates[0] = false;
          _isInitializing = false;
        });
      }
    }
  }

  bool _isPageChanging = false;
  Future<void> _onPageChanged(int index) async {
    if (_isPageChanging) return;
    _isPageChanging = true;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final videoState = _preloadedController.getVideoState(index);

    if (videoState != VideoState.ready) {
      setState(() => _loadingStates[index] = true);
    }

    // Pause all videos except the current one
    await _preloadedController.pauseAllExcept(index);

    // Preload the current video if not already ready
    if (videoState != VideoState.ready) {
      await _preloadedController.preloadVideo(index, videos[index].url);
      if (mounted) {
        setState(() => _loadingStates[index] = false);
      }
    }

    // Play the current video
    await _preloadedController.playVideo(index);

    // Preload the previous video (if it exists)
    if (index > 0) {
      _preloadedController.preloadVideo(index - 1, videos[index - 1].url);
    }

    // Preload two previous videos (before the previous one)
    if (index > 1) {
      _preloadedController.preloadVideo(index - 2, videos[index - 2].url);
    }

    // Preload the next video (if it exists)
    if (index < videos.length - 1) {
      _preloadedController.preloadVideo(index + 1, videos[index + 1].url);
    }

    // Preload two next videos (after the next one)
    if (index < videos.length - 2) {
      _preloadedController.preloadVideo(index + 2, videos[index + 2].url);
    }

    if (index - 3 >= 0) {
      await _preloadedController.disposeController(index - 3);
      _loadingStates.remove(index - 3);
    }

    
    if (index + 3 < videos.length) {
      await _preloadedController.disposeController(index + 3);
      _loadingStates.remove(index + 3);
    }

    _isPageChanging = false;
  }

  Widget _buildVideoItem(int index) {
    final video = videos[index];
    final controller = _preloadedController.getController(index);
    final videoState = _preloadedController.getVideoState(index);
    final bufferingProgress = _preloadedController.getBufferingProgress(index);
    final isLoading = _loadingStates[index] ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail layer - show only if video is not initialized
        if (controller == null || videoState == VideoState.initializing)
          Image.network(
            video.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),

        // Video layer (when ready)
        if (controller != null && videoState != VideoState.initializing)
          VideoPlayerItem(
            key: ValueKey('video_$index'),
            controller: controller,
            title: video.title,
            bufferingProgress: bufferingProgress,
            videoState: videoState,
          ),

        // Loading overlay only when the video is initializing
        if (isLoading || videoState == VideoState.initializing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),

        // Title - always visible
        Positioned(
          left: 16,
          bottom: 16,
          child: Text(
            video.title,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitializing
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Show first video thumbnail during initialization
                if (videos.isNotEmpty)
                  Image.network(
                    videos[0].thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.black);
                    },
                  ),
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                if (videos.isNotEmpty)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      videos[0].title,
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
              ],
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _buildVideoItem(index),
            ),
    );
  }

  @override
  void dispose() {
    _preloadedController.dispose();
    _pageController.dispose();
    _loadingStates.clear();
    super.dispose();
  }
}
