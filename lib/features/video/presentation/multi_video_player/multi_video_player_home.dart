import 'package:flutter/material.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_item.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:tavsta_preload_page_view/tavsta_preload_page_view.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to display preloaded videos inside page view.
//ignore: must_be_immutable
class MultiVideoPlayer extends StatefulWidget {
  VideoSource sourceType;

  List<dynamic> videoSourceList;

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

  PreloadPageController? pageController;

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

  PreloadPageView _pageView() {
    return PreloadPageView.builder(
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
      itemBuilder: (context, index) => _child(index),
    );
  }

  MultiVideoItem _child(int index) {
    return MultiVideoItem(
      videoSource: videosList[index].videoSource,
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
            index: index,
            videoSource: videosList[index].videoSource);
      },
      onDispose: (int index) {
        videosList[index].videoPlayerController = null;
      },
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
}
