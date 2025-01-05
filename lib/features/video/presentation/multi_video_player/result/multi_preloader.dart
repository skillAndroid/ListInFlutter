import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_player_home.dart';
import 'package:video_player/video_player.dart';

class MultiVideosScreen extends StatefulWidget {
  const MultiVideosScreen({super.key});

  @override
  State<MultiVideosScreen> createState() => _MultiVideosScreenState();
}

class _MultiVideosScreenState extends State<MultiVideosScreen> {
  // Mock data list
  final List<dynamic> mockVideos = [
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
  ];

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
  bool _isDisposing = false;

  @override
  void dispose() {
    _isDisposing = true;
    _cleanupAndDispose();
    super.dispose();
  }

  Future<void> _cleanupAndDispose() async {
    try {
      // First pause all playing videos
      await MultiVideo.pauseAndReleaseControllers();
      // Then dispose all controllers
      await MultiVideo.disposeAllControllers();
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  Future<void> _handleBackPress() async {
    if (_isDisposing) return;

    setState(() {
      _isDisposing = true;
    });

    try {
      // Ensure videos are paused first
      await MultiVideo.pauseAndReleaseControllers();
      // Then dispose all controllers
      await MultiVideo.disposeAllControllers();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error during back navigation: $e');
      // Still pop even if there's an error
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateToNewScreen() async {
    await MultiVideo.pauseAndReleaseControllers();
    if (mounted) {
      context.push(
        Routes.productDetails.replaceAll(':id', product.id),
        extra: getRecommendedProducts(product.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await _handleBackPress();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Feed'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToNewScreen,
          ),
        ),
        body: MultiVideoPlayer.network(
          height: double.infinity,
          width: MediaQuery.of(context).size.width,
          videoSourceList: mockVideos,
          scrollDirection: Axis.vertical,
          preloadPagesCount: 2,
          videoPlayerOptions: VideoPlayerOptions(),
          onPageChanged: (videoPlayerController, index) {
            // Handle page change if needed
            debugPrint('Changed to video index: $index');
          },
          getCurrentVideoController: (videoPlayerController) {
            if (videoPlayerController?.value.hasError ?? false) {
              debugPrint(
                'Video error: ${videoPlayerController?.value.errorDescription}',
              );
            }
          },
        ),
      ),
    );
  }
}
