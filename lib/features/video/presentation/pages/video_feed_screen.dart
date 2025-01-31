// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/video/presentation/wigets/video_controlls.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class ListInShorts extends StatefulWidget {
  final List<GetPublicationEntity> initialVideos;
  final int initialPage;
  final int initialIndex;

  const ListInShorts({
    super.key,
    required this.initialVideos,
    this.initialPage = 0,
    this.initialIndex = 0,
  });

  @override
  _ListInShortsState createState() => _ListInShortsState();
}

class _ListInShortsState extends State<ListInShorts> {
  late PageController _pageController;
  late HomeTreeCubit _homeTreeCubit;

  List<VideoPlayerController?> _controllers = [];
  int _currentIndex = 0;
  final Map<int, Duration> _videoPositions = {};
  bool _isLoading = false;
  List<GetPublicationEntity> _videos = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _videos = widget.initialVideos;
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.95);

    // Initialize controllers for current, previous, and next videos
    _initializeControllers();
  }

  void _loadMoreVideos() {
    if (_isLoading || _homeTreeCubit.state.videoHasReachedMax)
      return; // Prevent unnecessary requests

    setState(() {
      _isLoading = true;
    });

    _homeTreeCubit.fetchVideoFeeds(_videos.length ~/ 20);
  }

  void _initializeControllers() {
    // Create a list of null controllers based on video length
    _controllers = List.filled(
        widget.initialVideos.length < 3 ? widget.initialVideos.length : 3,
        null);

    // Initialize current video
    _initializeController(1, _currentIndex, fullLoad: true);

    // Initialize previous video if exists
    if (_currentIndex > 0) {
      _initializeController(0, _currentIndex - 1, fullLoad: false);
    }

    // Initialize next video if exists
    if (_currentIndex + 1 < widget.initialVideos.length) {
      _initializeController(2, _currentIndex + 1, fullLoad: false);
    }
  }

  void _initializeController(int controllerIndex, int videoIndex,
      {required bool fullLoad}) {
    if (_controllers[controllerIndex] == null) {
      try {
        final videoUrl =
            "https://${widget.initialVideos[videoIndex].videoUrl!}";
        debugPrint("Attempting to load video: $videoUrl");

        final controller = VideoPlayerController.network(
          videoUrl,
          httpHeaders: {
            if (!fullLoad) 'Range': 'bytes=0-500000',
          },
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false,
            mixWithOthers: true,
          ),
        );

        _controllers[controllerIndex] = controller;

        controller.initialize().then((_) {
          if (mounted) setState(() {});
          if (fullLoad) controller.play();
        }).catchError((error) {
          debugPrint("Video initialization error for $videoUrl: $error");

          // Fallback to full load if buffer load fails
          if (!fullLoad) {
            _initializeController(controllerIndex, videoIndex, fullLoad: true);
          }
        });
      } catch (e) {
        debugPrint(
            "Unexpected error during video controller initialization: $e");
      }
    }
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    // Store current video position
    final currentController = _controllers[1];
    if (currentController != null && currentController.value.isInitialized) {
      _videoPositions[_currentIndex] = currentController.value.position;
    }

    // Manage controllers when scrolling
    if (newIndex > _currentIndex) {
      // Scrolling forward
      _disposeController(0); // Dispose previous video controller
      _controllers[0] = _controllers[1];
      _controllers[1] = _controllers[2];
      _controllers[2] = null;

      // Initialize next video if available
      if (newIndex + 1 < widget.initialVideos.length) {
        _initializeController(2, newIndex + 1, fullLoad: false);
      }
    } else {
      // Scrolling backward
      _disposeController(2); // Dispose next video controller
      _controllers[2] = _controllers[1];
      _controllers[1] = _controllers[0];
      _controllers[0] = null;

      // Initialize previous video if available
      if (newIndex > 0) {
        _initializeController(0, newIndex - 1, fullLoad: false);
      }
    }

    setState(() {
      _currentIndex = newIndex;
    });

    // Play current video and pause others
    _playCurrentVideo();
  }

  void _playCurrentVideo() {
    final currentController = _controllers[1];
    if (currentController != null) {
      currentController.play().then((_) {
        if (_videoPositions.containsKey(_currentIndex)) {
          currentController.seekTo(_videoPositions[_currentIndex]!);
        }
      });

      // Pause other controllers
      _controllers
          .where((ctrl) => ctrl != currentController)
          .forEach((ctrl) => ctrl?.pause());
    }
  }

  void _disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers[index] = null;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _pageController.dispose();
    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  Future<void> _navigateToNewScreen() async {
    final currentController = _controllers[2]; // Current playing controller

    // Store the current position if video is initialized
    if (currentController != null && currentController.value.isInitialized) {
      _videoPositions[_currentIndex] = currentController.value.position;
      await currentController.pause();
    }

    final product = ProductEntity(
      name: "iPhone 4 Pro Max stoladi srochno narx kelishilgan",
      images: [
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
      ],
      location: "Tashkent, Yashnobod",
      price: 205,
      isNew: true,
      id: "1",
    );

    if (mounted) {
      // Navigate and wait for return
      await context.push(
        Routes.productDetails.replaceAll(':id', product.id),
        extra: getRecommendedProducts(product.id),
      );

      // Resume video from stored position when returning
      if (mounted) {
        final controller = _controllers[2];
        if (controller != null && controller.value.isInitialized) {
          final storedPosition = _videoPositions[_currentIndex];
          if (storedPosition != null) {
            await controller.seekTo(storedPosition);
            await controller.play();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // for Android
      statusBarBrightness: Brightness.dark, // for iOS
    ));
    return BlocListener<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {
        if (state.videoPublicationsRequestState == RequestState.completed) {
          setState(() {
            _videos.addAll(state.videoPublications);
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _videos.length,
            onPageChanged: (index) {
              _handlePageChange(index);
              if (!_isLoading && index >= _videos.length - 5) {
                _loadMoreVideos();
              }
            },
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final videoController = index == _currentIndex
                  ? _controllers[1]
                  : (index < _currentIndex ? _controllers[0] : _controllers[2]);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                shape: SmoothRectangleBorder(
                  smoothness: 0.85,
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (videoController != null &&
                        videoController
                            .value.isInitialized) // Changed condition here
                      ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: videoController,
                        builder: (context, value, child) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              if (value.isInitialized)
                                SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: value.size.width,
                                      height: value.size.height,
                                      child: VideoPlayer(videoController),
                                    ),
                                  ),
                                ),
                              ControlsOverlay(
                                controller: videoController,
                              ),
                              if (value.isBuffering)
                                Center(
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: Progress(),
                                  ),
                                ),
                            ],
                          );
                        },
                      )
                    else
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                "https://${widget.initialVideos[index].productImages[0].url}",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Center(
                            child: Transform.scale(
                              scale: 0.75,
                              child: CircularProgressIndicator(
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 64,
                      child: GestureDetector(
                        onTap: () {
                          _navigateToNewScreen();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SmoothClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  side: BorderSide(
                                      width: 2,
                                      color: AppColors.white.withOpacity(0.8)),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(
                                      "https://${widget.initialVideos[index].productImages[0].url}",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TechStore Official',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '2.5M followers',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Follow',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                clipBehavior: Clip.antiAlias,
                                shape: SmoothRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: AppColors.white.withOpacity(0.75),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SmoothClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: BorderSide(
                                              width: 2,
                                              color: AppColors.white,
                                            ),
                                            child: SizedBox(
                                              width: 76,
                                              height: 76,
                                              child: Image.network(
                                                "https://${widget.initialVideos[index].productImages[0].url}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.initialVideos[index]
                                                      .title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'High-quality sound with active noise cancellation',
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 3),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 8.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        '\$199.99',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Icon(Ionicons
                                                          .arrow_forward)
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(
                          Ionicons.close,
                          size: 28,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
