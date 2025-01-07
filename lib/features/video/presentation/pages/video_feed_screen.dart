import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/video/presentation/wigets/video_controlls.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class ListInShorts extends StatefulWidget {
  final List<AdvertisedProductEntity> data;

  const ListInShorts({super.key, required this.data});

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
    null,
  ];
  int _currentIndex = 0;
  final Map<int, Duration> _videoPositions = {}; // Store video positions

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.95);
    _initializeControllers(_currentIndex);
  }

  void _initializeControllers(int index) {
    // Initialize current video with full load
    _initializeController(2, index, fullLoad: true);

    // Preload previous video with buffer
    if (index > 0) _initializeController(1, index - 1, fullLoad: false);

    // Preload next video with buffer
    if (index + 1 < widget.data.length) {
      _initializeController(3, index + 1, fullLoad: false);
    }

    // Preload after next video with buffer
    if (index + 2 < widget.data.length) {
      _initializeController(4, index + 2, fullLoad: false);
    }

    // Preload after after next video with buffer
    if (index + 3 < widget.data.length) {
      _initializeController(0, index + 3, fullLoad: false);
    }
  }

  void _initializeController(int position, int index,
      {required bool fullLoad}) {
    if (_controllers[position] == null) {
      // ignore: deprecated_member_use
      final controller = VideoPlayerController.network(
        widget.data[index].videoUrl,
        httpHeaders: {
          if (!fullLoad) 'Range': 'bytes=0-500000',
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

    final currentController = _controllers[2];
    if (currentController != null && currentController.value.isInitialized) {
      _videoPositions[_currentIndex] = currentController.value.position;
    }

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

      if (newIndex + 3 < widget.data.length) {
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
    if (_controllers[2] != null) {
      _controllers[2]?.play().then((_) {
        if (_videoPositions.containsKey(newIndex)) {
          _controllers[2]?.seekTo(_videoPositions[newIndex]!);
        }
      });
    }
    for (int i = 0; i < _controllers.length; i++) {
      if (i != 2) _controllers[i]?.pause();
    }
  }

  void pauseControllers() {
    _controllers[_currentIndex]?.pause();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _videoPositions.clear();
    _pageController.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.data.length,
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

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 7,
                                    strokeCap: StrokeCap.round,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
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
                          imageUrl: widget.data[index].thumbnailUrl,
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
                                  width: 80,
                                  height: 84,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.data[index].thumbnailUrl,
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
                                    widget.data[index].price,
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
                                    widget.data[index].title,
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
                                        widget.data[index].userName,
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
                                        widget.data[index].userRating
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      Text(
                                        "(${widget.data[index].reviewsCount})",
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
    );
  }
}
