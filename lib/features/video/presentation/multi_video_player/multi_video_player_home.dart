import 'package:flutter/material.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_item.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:list_in/features/video/presentation/wigets/preload_page/preload_page.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to display preloaded videos inside page view.
//ignore: must_be_immutable
class MultiVideoPlayer extends StatefulWidget {
  VideoSource sourceType;

  List<AdvertisedProductEntity> videoSourceList;

  Axis scrollDirection;

  int preloadPagesCount;

  VideoPlayerOptions? videoPlayerOptions;
  Future<ClosedCaptionFile>? closedCaptionFile;
  Map<String, String>? httpHeaders;
  VideoFormat? formatHint;
  String? package;

  bool showControlsOverlay;
  bool showVideoProgressIndicator;

  double height;
  double width;

  /// getCurrentVideoController return the current playing video controller
  Function(VideoPlayerController? videoPlayerController)?
      getCurrentVideoController;

  Function(VideoPlayerController? videoPlayerController, int index)?
      onPageChanged;
  ScrollPhysics? scrollPhysics;
  bool reverse;
  bool pageSnapping;

  PreloadPageControllerListIn? pageController;
  final VoidCallback onProductTap;

  @override
  State<MultiVideoPlayer> createState() => _MultiVideoPlayerState();

  MultiVideoPlayer.network({
    super.key,
    required this.videoSourceList,
    required this.height,
    required this.width,
    this.scrollDirection = Axis.horizontal,
    this.preloadPagesCount = 1,
    this.videoPlayerOptions,
    this.httpHeaders,
    this.formatHint,
    this.closedCaptionFile,
    this.scrollPhysics,
    this.reverse = false,
    this.pageSnapping = true,
    this.pageController,
    this.getCurrentVideoController,
    this.onPageChanged,
    this.showControlsOverlay = true,
    this.showVideoProgressIndicator = true,
    required this.onProductTap,
  }) : sourceType = VideoSource.network;
}

class _MultiVideoPlayerState extends State<MultiVideoPlayer> {
  bool isLoading = true;
  List<MultiVideo> videosList = [];

  @override
  void initState() {
    super.initState();
    _generateVideoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: widget.height,
        width: widget.width,
        child: videosList.isEmpty
            ? const Center(child: Icon(Icons.error))
            : isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _pageView(),
      ),
    );
  }

  PreloadPageViewListIn _pageView() {
    return PreloadPageViewListIn.builder(
      itemCount: videosList.length,
      physics: widget.scrollPhysics,
      reverse: widget.reverse,
      controller: widget.pageController,
      pageSnapping: widget.pageSnapping,
      scrollDirection: widget.scrollDirection,
      preloadPagesCount: widget.preloadPagesCount > videosList.length
          ? 1
          : widget.preloadPagesCount,
      onPageChanged: (int index) => _onPageChange(index),
      itemBuilder: (context, index) => _buildVideoItem(index),
    );
  }

  Widget _buildVideoItem(int index) {
    final product = widget.videoSourceList[index];
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: widget.scrollDirection == Axis.vertical ? 8.0 : 0,
        horizontal: widget.scrollDirection == Axis.horizontal ? 8.0 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black,
      ),
      clipBehavior:
          Clip.antiAlias, // This ensures the video respects the border radius
      child: Stack(
        fit: StackFit.expand,
        children: [
          MultiVideoItem(
            videoSource: product,
            index: index,
            sourceType: widget.sourceType,
            videoPlayerOptions: widget.videoPlayerOptions,
            closedCaptionFile: widget.closedCaptionFile,
            showControlsOverlay: widget.showControlsOverlay,
            showVideoProgressIndicator: widget.showVideoProgressIndicator,
            onInit: (VideoPlayerController videoPlayerController) {
              if (index == MultiVideo.currentIndex) {
                widget.getCurrentVideoController?.call(videoPlayerController);
              }
              videosList[index].updateVideo(
                videoPlayerController: videoPlayerController,
                videoSource: product.videoUrl,
                index: index,
              );
            },
            onProductTap: widget.onProductTap,
            onDispose: (int index) {
              videosList[index].videoPlayerController = null;
            },
          ),
        ],
      ),
    );
  }

  _onPageChange(int index) {
    MultiVideo.currentIndex = index;
    widget.getCurrentVideoController
        ?.call(videosList[index].videoPlayerController);
    widget.onPageChanged?.call(videosList[index].videoPlayerController, index);
    videosList[index].playVideo(index);
  }

  Future<void> _generateVideoList() async {
    await Future.forEach(widget.videoSourceList, (source) async {
      videosList.add(MultiVideo(videoSource: source));
    });
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> disposeAllControllers() async {
    try {
      for (var video in videosList) {
        if (video.videoPlayerController != null) {
          if (video.videoPlayerController!.value.isPlaying) {
            await video.videoPlayerController!.pause();
          }
          await video.videoPlayerController!.dispose();
          video.videoPlayerController = null;
        }
      }
      MultiVideo.currentIndex = 0;
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }
  }

  /// Pauses current video and releases controller resources temporarily
  /// Use this when navigating to another screen but planning to return
  Future<void> pauseAndReleaseControllers() async {
    try {
      // Pause and release current video
      if (MultiVideo.currentIndex < videosList.length) {
        var currentVideo = videosList[MultiVideo.currentIndex];
        if (currentVideo.videoPlayerController != null) {
          if (currentVideo.videoPlayerController!.value.isPlaying) {
            await currentVideo.videoPlayerController!.pause();
          }
          await currentVideo.videoPlayerController!.setVolume(0);
        }
      }

      // Release preloaded videos
      for (var video in videosList) {
        if (video.index != MultiVideo.currentIndex &&
            video.videoPlayerController != null) {
          await video.videoPlayerController!.pause();
          await video.videoPlayerController!.dispose();
          video.videoPlayerController = null;
        }
      }
    } catch (e) {
      debugPrint('Error pausing controllers: $e');
    }
  }
}
