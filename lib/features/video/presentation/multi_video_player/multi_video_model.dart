import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum VideoSource { network, file, asset }
class MultiVideo {
  static int currentIndex = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  static final List<MultiVideo> _instances = [];
  
  final dynamic videoSource;
  int index;
  VideoPlayerController? videoPlayerController;
  int _retryCount = 0;

  MultiVideo({
    required this.videoSource,
    this.videoPlayerController,
    this.index = 0,
  }) {
    _instances.add(this);
  }

  static Future<void> disposeAllControllers() async {
    try {
      for (var video in _instances) {
        if (video.videoPlayerController != null) {
          try {
            if (video.videoPlayerController!.value.isPlaying) {
              await video.videoPlayerController!.pause();
            }
            await video.videoPlayerController!.dispose();
          } catch (e) {
            debugPrint('Error disposing controller for index ${video.index}: $e');
          } finally {
            video.videoPlayerController = null;
          }
        }
      }
      currentIndex = 0;
      _instances.clear();
    } catch (e) {
      debugPrint('Error in disposeAllControllers: $e');
    }
  }

  static Future<void> pauseAndReleaseControllers() async {
    try {
      if (currentIndex < _instances.length) {
        var currentVideo = _instances[currentIndex];
        if (currentVideo.videoPlayerController != null) {
          try {
            if (currentVideo.videoPlayerController!.value.isPlaying) {
              await currentVideo.videoPlayerController!.pause();
            }
            await currentVideo.videoPlayerController!.setVolume(0);
          } catch (e) {
            debugPrint('Error pausing current video: $e');
          }
        }
      }

      for (var video in _instances) {
        if (video.index != currentIndex && video.videoPlayerController != null) {
          try {
            await video.videoPlayerController!.pause();
            await video.videoPlayerController!.dispose();
            video.videoPlayerController = null;
          } catch (e) {
            debugPrint('Error releasing preloaded video at index ${video.index}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error in pauseAndReleaseControllers: $e');
    }
  }

  Future<void> playVideo(int index) async {
    if (index == currentIndex && videoPlayerController != null) {
      try {
        if (videoPlayerController!.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 100));
          await videoPlayerController!.play();
        }
      } catch (e) {
        debugPrint('Error playing video: $e');
        if (_retryCount < maxRetries) {
          _retryCount++;
          await Future.delayed(retryDelay);
          await playVideo(index);
        }
      }
    }
  }

  void updateVideo({
    VideoPlayerController? videoPlayerController,
    dynamic videoSource,
    int? index,
  }) {
    this.videoPlayerController = videoPlayerController;
    this.index = index ?? this.index;
    _retryCount = 0;
  }
}
