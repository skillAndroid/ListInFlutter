import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_player_home.dart';
import 'package:video_player/video_player.dart';

class MultiVideosScreen extends StatefulWidget {
  final List<AdvertisedProductEntity> source;
  const MultiVideosScreen({super.key, required this.source});

  @override
  State<MultiVideosScreen> createState() => _MultiVideosScreenState();
}

class _MultiVideosScreenState extends State<MultiVideosScreen> {
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
  bool _isNavigating = false;

  @override
  void dispose() {
    _isDisposing = true;
    _cleanupAndDispose();
    super.dispose();
  }

  Future<void> _cleanupAndDispose() async {
    try {
      await MultiVideo.pauseControllers();
      await MultiVideo.disposeAllControllers();
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  Future<void> _handleBackPress() async {
    if (_isDisposing || _isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }

    _cleanupResources();
  }

  Future<void> _cleanupResources() async {
    if (_isDisposing) return;
    _isDisposing = true;

    try {
      if (MultiVideo.currentIndex < MultiVideo.instances.length) {
        final currentVideo = MultiVideo.instances[MultiVideo.currentIndex];
        if (currentVideo.videoPlayerController?.value.isPlaying ?? false) {
          await currentVideo.videoPlayerController?.pause();
        }
      }
      unawaited(_completeCleanup());
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  Future<void> _completeCleanup() async {
    try {
      await MultiVideo.pauseControllers();
      await MultiVideo.disposeAllControllers();
    } catch (e) {
      debugPrint('Error during complete cleanup: $e');
    }
  }

  void _navigateToNewScreen() async {
    await MultiVideo.pauseControllers();
    if (mounted) {
      context.push(
        Routes.productDetails.replaceAll(':id', product.id),
        extra: getRecommendedProducts(product.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // for Android
      statusBarBrightness: Brightness.dark, // for iOS
    ));
    // ignore: deprecated_member_use
    return Container(
      color: Colors.black,
      child: SafeArea(
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () async {
            await _handleBackPress();
            return false;
          },
          child: MultiVideoPlayer.network(
            height: double.infinity,
            width: MediaQuery.of(context).size.width,
            videoSourceList: widget.source,
            scrollDirection: Axis.vertical,
            preloadPagesCount: 2,
            videoPlayerOptions: VideoPlayerOptions(),
            onPageChanged: (videoPlayerController, index) {
              debugPrint('Changed to video index: $index');
            },
            getCurrentVideoController: (videoPlayerController) {
              if (videoPlayerController?.value.hasError ?? false) {
                debugPrint(
                  'Video error: ${videoPlayerController?.value.errorDescription}',
                );
              }
            },
            onProductTap: _navigateToNewScreen,
          ),
        ),
      ),
    );
  }
}
