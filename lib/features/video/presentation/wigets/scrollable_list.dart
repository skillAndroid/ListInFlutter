// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoCarousel extends StatefulWidget {
  final List<AdvertisedProductEntity> items;

  const VideoCarousel({super.key, required this.items});

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isScrolling = false;
  bool _isVisible = true;
  Timer? _videoTimer;
  bool _shouldAutoAdvance = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.275, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isVisible) {
        _initializeVideo(_currentIndex);
      }
    });
  }

  Future<void> _clearVideo() async {
    _videoTimer?.cancel();
    if (_videoController != null) {
      _videoController?.removeListener(_checkVideoProgress);
      await _videoController?.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleNavigation() {
    if (_currentIndex < widget.items.length - 1) {
      _autoScrollToNextPage();
    } else {
      _clearVideo(); // End of content
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (widget.items.isEmpty || !_isVisible || index >= widget.items.length) {
      return;
    }

    await _clearVideo();

    _videoController =
        VideoPlayerController.network(widget.items[index].videoUrl);

    await _videoController?.initialize();

    if (mounted && _isVisible) {
      setState(() {});
      _videoController?.setLooping(false);
      _videoController?.play();
      _videoController?.setVolume(0);
      _videoController?.addListener(_checkVideoProgress);

      // Start the timer after video initialization
      _startVideoTimer();
    }
  }

  void _startVideoTimer() {
    _videoTimer?.cancel(); // Cancel any existing timer
    _videoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _isVisible && !_isScrolling) {
        if (_shouldAutoAdvance) {
          _handleNavigation(); // Auto-scroll to the next page
        } else {
          // Play next video without changing the visible page
          setState(() {
            _currentIndex =
                (_currentIndex + 1) % widget.items.length; // Loop if necessary
          });
          if (_currentIndex < widget.items.length) {
            _initializeVideo(_currentIndex); // Load the next video
          } else {
            _clearVideo(); // Stop at "See All Videos"
          }
        }
      }
    });
  }

  void _autoScrollToNextPage() {
    if (_currentIndex < widget.items.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _checkVideoProgress() {
    if (_videoController == null || !mounted || !_isVisible) return;

    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;

    if (position >= const Duration(seconds: 5) || position >= duration) {
      if (_shouldAutoAdvance) {
        _handleNavigation();
      } else {
        // Let the timer handle internal updates
      }
    }
  }

// Also update _onPageChanged to handle manual navigation better
  void _onPageChanged(int index) async {
    if (index == widget.items.length) {
      // Reached "See All Videos" page
      await _clearVideo();
    } else {
      setState(() {
        _isScrolling = true;
        _currentIndex = index;
      });

      // Update auto-advance behavior based on remaining videos
      final remainingPages = widget.items.length - index - 1;
      _shouldAutoAdvance = remainingPages >= 4;

      // Clear existing video before initializing new one
      await _clearVideo();

      if (_isVisible) {
        await _initializeVideo(index);
      }

      setState(() {
        _isScrolling = false;
      });
    }
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    _clearVideo();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('video-carousel'),
      onVisibilityChanged: (info) {
        final wasVisible = _isVisible;
        _isVisible = info.visibleFraction > 0.99;

        if (wasVisible != _isVisible) {
          if (_isVisible && _currentIndex < widget.items.length) {
            _initializeVideo(_currentIndex);
          } else {
            _clearVideo();
          }
        }
      },
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          padEnds: false,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: widget.items.length + 1,
          itemBuilder: (context, index) {
            if (index == widget.items.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: SmoothClipRRect(
                  side: BorderSide(width: 2, color: AppColors.white),
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () {
                      context.push(Routes.videosFeed);
                    },
                    child: Container(
                      height: 160,
                      width: 90,
                      color: AppColors.containerColor,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.play_circle_fill,
                            size: 32,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'See All\nVideos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final item = widget.items[index];
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: SmoothClipRRect(
                side: BorderSide(width: 2, color: AppColors.white),
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () {
                    context.push(Routes.videosFeed);
                  },
                  child: SizedBox(
                    height: 160,
                    width: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: item.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        if (index == _currentIndex &&
                            _videoController != null &&
                            _isVisible)
                          VideoPlayer(_videoController!),
                        if (index != _currentIndex ||
                            _videoController == null ||
                            !_isVisible)
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Icon(
                              CupertinoIcons.play_fill,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
