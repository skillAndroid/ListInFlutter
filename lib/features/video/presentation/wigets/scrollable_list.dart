// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VideoCarousel extends StatefulWidget {
  final List<GetPublicationEntity> items;

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
  bool _isVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isVisible) {
        _initializeVideo(_currentIndex);
      }
    });
  }

  Future<void> _clearVideo() async {
    try {
      _videoTimer?.cancel();
      if (_videoController != null) {
        _videoController?.removeListener(_checkVideoProgress);
        await _videoController?.dispose();
        _videoController = null;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error clearing video: $e');
    }
  }

  void _handleNavigation() {
    if (_currentIndex < widget.items.length - 1) {
      _autoScrollToNextPage();
    } else {
      _clearVideo();
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (widget.items.isEmpty ||
        !_isVisible ||
        index >= widget.items.length ||
        _isVideoInitializing) {
      return;
    }

    try {
      _isVideoInitializing = true;
      await _clearVideo();

      final videoUrl = widget.items[index].videoUrl;
      if (!await _isValidVideoUrl("https://$videoUrl")) {
        debugPrint('Invalid video URL: $videoUrl');
        return;
      }

      _videoController = VideoPlayerController.network(
        "https://$videoUrl",
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        httpHeaders: const {
          'Connection': 'keep-alive',
        },
      );

      bool initialized = false;
      try {
        await _videoController?.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Video initialization timed out');
          },
        );
        initialized = true;
      } catch (e) {
        debugPrint('Video initialization error: $e');
        await _clearVideo();
        return;
      }

      if (!mounted || !_isVisible) {
        await _clearVideo();
        return;
      }

      if (initialized) {
        setState(() {});

        try {
          await _videoController?.setLooping(false);
          await _videoController?.setVolume(0);
          _videoController?.addListener(_checkVideoProgress);
          await _videoController?.play();
          _startVideoTimer();
        } catch (e) {
          debugPrint('Video playback configuration error: $e');
          await _clearVideo();
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      await _clearVideo();
    } finally {
      _isVideoInitializing = false;
    }
  }

  Future<bool> _isValidVideoUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _startVideoTimer() {
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _isVisible && !_isScrolling) {
        if (_shouldAutoAdvance) {
          _handleNavigation();
        } else {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.items.length;
          });
          if (_currentIndex < widget.items.length) {
            _initializeVideo(_currentIndex);
          } else {
            _clearVideo();
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

    try {
      final duration = _videoController!.value.duration;
      final position = _videoController!.value.position;

      if (position >= const Duration(seconds: 5) || position >= duration) {
        if (_shouldAutoAdvance) {
          _handleNavigation();
        }
      }
    } catch (e) {
      debugPrint('Error checking video progress: $e');
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

  void _onVideoTap(int index) {
    final homeTreeCubit = context.read<HomeTreeCubit>();
    homeTreeCubit.handleVideoFeedNavigation(context, index);
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
        height: 185,
        child: PageView.builder(
          padEnds: false,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: widget.items.length + 1,
          itemBuilder: (context, index) {
            if (index == widget.items.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: GestureDetector(
                  onTap: () => context
                      .read<HomeTreeCubit>()
                      .handleVideoFeedNavigation(context, 0),
                  child: Container(
                    height: 182,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: AppColors.grey.withOpacity(0.75),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.play_circle_fill,
                          size: 32,
                          color: AppColors.black,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.see_all_videos,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final item = widget.items[index];
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: ClipSmoothRect(
                radius:
                    SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.8),
                child: GestureDetector(
                  onTap: () => _onVideoTap(index),
                  child: SizedBox(
                    height: 160,
                    width: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: "https://${item.productImages[0].url}",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: Progress(),
                          ),
                        ),
                        if (index == _currentIndex &&
                            _videoController != null &&
                            _isVisible)
                          Positioned.fill(
                            child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            ),
                          ),
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
