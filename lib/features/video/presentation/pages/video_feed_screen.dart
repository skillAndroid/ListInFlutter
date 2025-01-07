import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ListInShorts extends StatefulWidget {
  final List<String> videoUrls;

  const ListInShorts({super.key, required this.videoUrls});

  @override
  _ListInShortsState createState() => _ListInShortsState();
}

class _ListInShortsState extends State<ListInShorts> {
  late PageController _pageController;
  final List<VideoPlayerController?> _controllers = [
    null,
    null,
    null,
    null,
    null
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializeControllers(_currentIndex);
  }

  void _initializeControllers(int index) {
    // Initialize current video with full load
    _initializeController(2, index, fullLoad: true);

    // Preload previous video with buffer
    if (index > 0) _initializeController(1, index - 1, fullLoad: false);

    // Preload next video with buffer
    if (index + 1 < widget.videoUrls.length) {
      _initializeController(3, index + 1, fullLoad: false);
    }

    // Preload after next video with buffer
    if (index + 2 < widget.videoUrls.length) {
      _initializeController(4, index + 2, fullLoad: false);
    }

    // Preload after after next video with buffer
    if (index + 3 < widget.videoUrls.length) {
      _initializeController(0, index + 3, fullLoad: false);
    }
  }

  void _initializeController(int position, int index,
      {required bool fullLoad}) {
    if (_controllers[position] == null) {
      // ignore: deprecated_member_use
      final controller = VideoPlayerController.network(
        widget.videoUrls[index],
        httpHeaders: {
          if (!fullLoad)
            'Range': 'bytes=0-500000', // Load only 500KB for buffered videos
        },
      );
      _controllers[position] = controller;
      controller.initialize().then((_) {
        if (mounted) setState(() {});
        if (fullLoad) controller.play();
      });
    }
  }

  void _disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers[index] = null;
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    final previousIndex = _currentIndex;
    setState(() {
      _currentIndex = newIndex;
    });

    if (newIndex > previousIndex) {
      // Moving forward
      _disposeController(1); // Dispose of previous video
      _controllers[1] = _controllers[2];
      _controllers[2] = _controllers[3];
      _controllers[3] = _controllers[4];
      _controllers[4] = _controllers[0];
      _controllers[0] = null;

      if (newIndex + 3 < widget.videoUrls.length) {
        _initializeController(0, newIndex + 3, fullLoad: false);
      }
    } else {
      // Moving backward
      _disposeController(4); // Dispose of after after next video
      _controllers[4] = _controllers[3];
      _controllers[3] = _controllers[2];
      _controllers[2] = _controllers[1];
      _controllers[1] = _controllers[0];
      _controllers[0] = null;

      if (newIndex > 0) {
        _initializeController(0, newIndex - 1, fullLoad: false);
      }
    }

    // Play current video and pause others
    _controllers[2]?.play();
    for (int i = 0; i < _controllers.length; i++) {
      if (i != 2) _controllers[i]?.pause();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videoUrls.length,
        onPageChanged: _handlePageChange,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final videoController = _controllers[index == _currentIndex
              ? 2
              : (index < _currentIndex
                  ? 1
                  : index == _currentIndex + 1
                      ? 3
                      : index == _currentIndex + 2
                          ? 4
                          : 0)];

          return Stack(
            fit: StackFit.expand,
            children: [
              if (videoController?.value.isInitialized ?? false)
                VideoPlayer(videoController!)
              else
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
