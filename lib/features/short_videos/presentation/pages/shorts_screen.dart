// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoData {
  final String url;
  final String thumbnail;
  final String title;

  VideoData({
    required this.url,
    required this.thumbnail,
    required this.title,
  });
}

class VideoPreloader extends StatefulWidget {
  const VideoPreloader({super.key});

  @override
  _VideoPreloaderState createState() => _VideoPreloaderState();
}

class _VideoPreloaderState extends State<VideoPreloader> with TickerProviderStateMixin {
  // Initial video list
  final List<VideoData> _initialVideos = [
    VideoData(
      url:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnail: 'https://i.imgur.com/YEpFEAz.jpg',
      title: 'Busy Bee',
    ),
    VideoData(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnail: 'https://i.imgur.com/L5V2bad.jpg',
      title: 'For Bigger Blazes',
    ),
    VideoData(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnail: 'https://i.imgur.com/xwuZyQf.jpg',
      title: 'Elephants Dream',
    ),
    VideoData(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnail: 'https://i.imgur.com/mZFTqr3.jpg',
      title: 'Big Buck Bunny',
    ),
  ];

  // Additional videos to load when reaching the end
  final List<VideoData> _moreVideos = [
    VideoData(
      url:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      thumbnail: 'https://i.imgur.com/gVUcYhO.jpg',
      title: 'Tears of Steel',
    ),
    VideoData(
      url: 'https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      thumbnail: 'https://i.imgur.com/RWB6zqp.jpg',
      title: 'Sintel',
    ),
    // Add more videos as needed
  ];

  late List<VideoData> videoList;
  late List<VideoPlayerController?> videoPlayerControllers;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  int _currentPage = 1;
  
  final Map<int, bool> _initializedVideos = {};
  final Map<int, Completer<void>> _initializationCompleters = {};

  @override
  void initState() {
    super.initState();
    videoList = List.from(_initialVideos);
    videoPlayerControllers = List.generate(videoList.length, (_) => null);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _initializeFirstVideos();
  }

  Future<void> _initializeFirstVideos() async {
    // Initialize first two videos
    await Future.wait([
      _initializeVideoAtIndex(0),
      _initializeVideoAtIndex(1),
    ]);

    if (mounted) {
      await _playVideoAtIndex(0);
    }
  }

  Future<void> _initializeVideoAtIndex(int index) async {
    if (!_isValidIndex(index) || _initializedVideos[index] == true) {
      return;
    }

    if (_initializationCompleters[index] != null) {
      return _initializationCompleters[index]!.future;
    }

    final completer = Completer<void>();
    _initializationCompleters[index] = completer;

    try {
      final controller = VideoPlayerController.network(videoList[index].url);
      videoPlayerControllers[index] = controller;

      await controller.initialize();
      
      if (mounted) {
        setState(() {
          _initializedVideos[index] = true;
        });
      }

      completer.complete();
    } catch (e) {
      print('Error initializing video at index $index: $e');
      _initializedVideos[index] = false;
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<void> _playVideoAtIndex(int index) async {
    if (!_isValidIndex(index)) return;

    if (!_initializedVideos[index]!) {
      await _initializeVideoAtIndex(index);
    }

    final controller = videoPlayerControllers[index];
    if (controller != null && controller.value.isInitialized) {
      await controller.play();
      controller.setLooping(true);
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final startIndex = (_currentPage - 1) % _moreVideos.length;
      final videosToAdd = _moreVideos.sublist(
        startIndex,
        startIndex + (_moreVideos.length > 2 ? 2 : _moreVideos.length),
      );

      setState(() {
        final newStartIndex = videoList.length;
        videoList.addAll(videosToAdd);
        videoPlayerControllers.addAll(List.generate(videosToAdd.length, (_) => null));
        
        for (var i = 0; i < videosToAdd.length; i++) {
          _initializedVideos[newStartIndex + i] = false;
        }
        
        _currentPage++;
      });

      // Initialize new videos in background
      for (var i = 0; i < videosToAdd.length; i++) {
        _initializeVideoAtIndex(videoList.length - videosToAdd.length + i);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 void _onPageChanged(int index) async {
    if (!_isValidIndex(index)) return;

    setState(() {
      currentIndex = index;
    });

    _fadeController.forward(from: 0.0);

    // Stop previous video if it exists and index is valid
    if (index > 0 && _isValidIndex(index - 1)) {
      final previousController = videoPlayerControllers[index - 1];
      if (previousController != null) {
        await previousController.pause();
        // Optionally reset to beginning
        await previousController.seekTo(Duration.zero);
      }
    }

    // Play current video
    await _playVideoAtIndex(index);

    // Preload next video if exists
    if (_isValidIndex(index + 1)) {
      _initializeVideoAtIndex(index + 1);
    }

    // Load more videos if needed
    if (index >= videoList.length - 2) {
      _loadMoreVideos();
    }

    // Cleanup old controllers to free up memory
    // Only dispose controllers that are more than 2 positions away
    for (int i = 0; i < videoList.length; i++) {
      if ((i < index - 2 || i > index + 2) && 
          videoPlayerControllers[i] != null && 
          _initializedVideos[i] == true) {
        await videoPlayerControllers[i]!.dispose();
        videoPlayerControllers[i] = null;
        _initializedVideos[i] = false;
      }
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < videoList.length;
  }

  Widget _buildVideoPlayer(int index) {
    if (!_isValidIndex(index)) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Black background
          Container(color: Colors.black),

          // Thumbnail
          CachedNetworkImage(
            imageUrl: videoList[index].thumbnail,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(color: Colors.black),
            errorWidget: (context, url, error) => Container(color: Colors.black),
          ),

          // Video player
          if (_initializedVideos[index] == true && videoPlayerControllers[index] != null)
            VideoPlayer(videoPlayerControllers[index]!),

          // Play/Pause overlay
          if (!_isPlaying)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 64),
              ),
            ),

          // Title
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                videoList[index].title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_initializedVideos[index] != true)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoList.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final controller = videoPlayerControllers[index];
              if (controller != null && controller.value.isInitialized) {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying ? controller.play() : controller.pause();
                });
              }
            },
            child: _buildVideoPlayer(index),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in videoPlayerControllers) {
      controller?.dispose();
    }
    super.dispose();
  }
}