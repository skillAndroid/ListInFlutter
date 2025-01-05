import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum VideoSource { network, file, asset }

class MultiVideo {
  static int currentIndex = 0;
  dynamic videoSource;
  int index;
  VideoPlayerController? videoPlayerController;

  MultiVideo(
      {required this.videoSource, this.videoPlayerController, this.index = 0});

  void playVideo(int index) {
    if (index == currentIndex && videoPlayerController != null) {
      try {
        if (videoPlayerController!.value.isInitialized) {
          videoPlayerController!.play();
        }
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  void updateVideo({videoSource, videoPlayerController, index}) {
    this.videoPlayerController = videoPlayerController;
    this.videoSource = videoSource;
    this.index = index;
  }
}
