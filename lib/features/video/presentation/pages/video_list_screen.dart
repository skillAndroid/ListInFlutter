// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_item.dart';
import 'package:list_in/features/video/presentation/wigets/preloaded_video_controller.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatefulWidget {
  final List<AdvertisedProductEntity> videos;
  const VideoListScreen({super.key, required this.videos});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final PreloadedVideoController _preloadedController = PreloadedVideoController();
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isPageChanging = false;
  final Map<int, _VideoState> _videoStates = {};
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _initializeFirstVideo();
  }

  Future<void> _initializeFirstVideo() async {
    try {
      _updateVideoState(0, _VideoState(status: VideoStatus.loading));
      
      await _preloadedController.preloadVideo(0, widget.videos[0].videoUrl);
      
      final controller = _preloadedController.getController(0);
      if (controller != null) {
        controller.addListener(() => _handleVideoStateChange(0, controller));
        
        if (mounted) {
          await controller.initialize();
          
          _updateVideoState(0, _VideoState(
            status: VideoStatus.ready,
            isPlaying: false,
            position: controller.value.position,
            duration: controller.value.duration,
          ));
          
          await _playVideo(0);
          
          // Preload next video
          if (widget.videos.length > 1) {
            _preloadNext(1);
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing first video: $e');
      _updateVideoState(0, _VideoState(status: VideoStatus.error));
    }
  }

  Future<void> _preloadNext(int index) async {
    if (index >= widget.videos.length) return;
    if (_videoStates[index]?.status == VideoStatus.ready) return;
    
    try {
      await _preloadedController.preloadVideo(index, widget.videos[index].videoUrl);
      final controller = _preloadedController.getController(index);
      
      if (controller != null) {
        controller.addListener(() => _handleVideoStateChange(index, controller));
        await controller.initialize();
        
        _updateVideoState(index, _VideoState(
          status: VideoStatus.ready,
          isPlaying: false,
          position: controller.value.position,
          duration: controller.value.duration,
        ));
      }
    } catch (e) {
      debugPrint('Error preloading video at index $index: $e');
    }
  }

  void _handleVideoStateChange(int index, VideoPlayerController controller) {
    if (!mounted) return;

    if (controller.value.hasError) {
      _updateVideoState(index, _VideoState(status: VideoStatus.error));
      return;
    }

    final currentState = _videoStates[index];
    if (currentState == null) return;

    // Only update state if there's a meaningful change
    if (_currentIndex == index || controller.value.isBuffering) {
      _updateVideoState(
        index,
        _VideoState(
          status: VideoStatus.ready,
          isPlaying: controller.value.isPlaying,
          position: controller.value.position,
          duration: controller.value.duration,
          isBuffering: controller.value.isBuffering,
        ),
      );
    }

    // Ensure other videos are paused
    if (_currentIndex != index && controller.value.isPlaying) {
      controller.pause();
    }
  }

  Future<void> _onPageChanged(int index) async {
    if (_isPageChanging) return;
    _isPageChanging = true;

    final oldIndex = _currentIndex;
    _currentIndex = index;

    try {
      // Pause the previous video
      await _pauseVideo(oldIndex);

      // Handle the new current video
      final videoState = _videoStates[index];
      final controller = _preloadedController.getController(index);

      if (videoState?.status != VideoStatus.ready || controller == null) {
        // Show loading state only if video isn't ready
        _updateVideoState(index, _VideoState(status: VideoStatus.loading));
        
        // Wait for video to be ready
        await _preloadedController.preloadVideo(index, widget.videos[index].videoUrl);
        final newController = _preloadedController.getController(index);
        
        if (newController != null) {
          await newController.initialize();
          newController.addListener(() => _handleVideoStateChange(index, newController));
          
          _updateVideoState(index, _VideoState(
            status: VideoStatus.ready,
            isPlaying: false,
            position: newController.value.position,
            duration: newController.value.duration,
          ));
        }
      }

      // Play the current video if it's ready
      if (_videoStates[index]?.status == VideoStatus.ready) {
        await _playVideo(index);
      }

      // Preload adjacent videos
      if (index > 0) {
        _preloadNext(index - 1);
      }
      if (index < widget.videos.length - 1) {
        _preloadNext(index + 1);
      }

      // Cleanup distant videos
      await _cleanupDistantVideos(index);
    } catch (e) {
      debugPrint('Error during page change: $e');
      _updateVideoState(index, _VideoState(status: VideoStatus.error));
    } finally {
      _isPageChanging = false;
    }
  }

  Future<void> _playVideo(int index) async {
    if (_videoStates[index]?.status != VideoStatus.ready) return;
    
    final controller = _preloadedController.getController(index);
    if (controller != null && !controller.value.isPlaying) {
      await controller.play();
      _updateVideoState(
        index,
        _VideoState(
          status: VideoStatus.ready,
          isPlaying: true,
          position: controller.value.position,
          duration: controller.value.duration,
        ),
      );
    }
  }

  Future<void> _pauseVideo(int index) async {
    final controller = _preloadedController.getController(index);
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
      _updateVideoState(
        index,
        _VideoState(
          status: VideoStatus.ready,
          isPlaying: false,
          position: controller.value.position,
          duration: controller.value.duration,
        ),
      );
    }
  }

  Future<void> _cleanupDistantVideos(int currentIndex) async {
    final visibleRange = 2;
    for (final entry in _videoStates.entries.toList()) {
      final index = entry.key;
      if ((index - currentIndex).abs() > visibleRange) {
        await _preloadedController.disposeController(index);
        _videoStates.remove(index);
      }
    }
  }

  void _updateVideoState(int index, _VideoState state) {
    if (mounted) {
      setState(() {
        _videoStates[index] = state;
      });
    }
  }

  Widget _buildVideoItem(int index) {
    final video = widget.videos[index];
    final videoState = _videoStates[index];
    final controller = _preloadedController.getController(index);

    return GestureDetector(
      onTap: () async {
        if (videoState?.status == VideoStatus.ready) {
          if (videoState!.isPlaying) {
            await _pauseVideo(index);
          } else {
            await _playVideo(index);
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoState?.status != VideoStatus.ready)
              Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),

            // Video layer
             if (controller != null && videoState?.status == VideoStatus.ready)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),

           if (videoState?.status == VideoStatus.loading || videoState?.isBuffering == true)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Transform.scale(
                    scale:
                        0.7, // Adjust this value to make it smaller (0.5 = half size, 1.0 = normal size)
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                      strokeWidth: 7,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ),
              ),

          
            Positioned(
              left: 24,
              right: 24,
              bottom: 64,
              child: GestureDetector(
                onTap: () {},
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    height: 84,
                    color: Colors.white,
                    child: Row(
                      children: [
                        SmoothClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 84,
                            height: 80,
                            child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              video.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  video.userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                                Icon(
                                  Icons.star,
                                  color: CupertinoColors.activeOrange,
                                ),
                                Text(
                                  video.userRating.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                                Text(
                                  "(${video.reviewsCount})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

         
            if (controller != null && videoState?.status == VideoStatus.ready)
              ControlsOverlay(
                controller: controller,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: widget.videos.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) => _buildVideoItem(index),
        ),
      ),
    );
  }
}

// Strict video state management
enum VideoStatus {
  initial,
  loading,
  ready,
  error,
}

class _VideoState {
  final VideoStatus status;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isBuffering;

  _VideoState({
    this.status = VideoStatus.initial,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isBuffering = false,
  });
}
