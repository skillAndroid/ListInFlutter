// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

enum VideoState { none, initializing, buffering, ready, error }

class PreloadedVideoController {
   final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, VideoState> _videoStates = {};
  bool _isDisposed = false;
  final Map<int, double> _bufferingProgress = {};
  
  VideoState getVideoState(int index) => _videoStates[index] ?? VideoState.none;
  double getBufferingProgress(int index) => _bufferingProgress[index] ?? 0.0;

  Future<void> preloadVideo(int index, String url) async {
    if (_isDisposed) return;

    if (_videoStates[index] == VideoState.ready ||
        _videoStates[index] == VideoState.buffering) {
      return;
    }

    try {
      await _cleanupController(index);

      _videoStates[index] = VideoState.initializing;
      _bufferingProgress[index] = 0.0;

      final initialChunkSize = 512 * 1024;

      final controller = VideoPlayerController.network(
        url,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: true,
        ),
        httpHeaders: {
          'Range': 'bytes=0-$initialChunkSize',
        },
      );

      _controllers[index] = controller;

      // Optimize buffering listener
      StreamController<VideoState>? stateController;
      stateController = StreamController<VideoState>();

      controller.addListener(() {
        if (_isDisposed) {
          stateController?.close();
          return;
        }

        _updateBufferingState(controller, index);

        // Throttle checking for more content
        if (!controller.value.isBuffering) {
          _checkAndLoadMoreContent(controller, index, url);
        }
      });

      await controller.initialize();

      if (_isDisposed) {
        stateController.close();
        await _cleanupController(index);
        return;
      }

      await controller.setLooping(true);
      _videoStates[index] = VideoState.ready;
    } catch (e) {
      debugPrint('Error loading video at index $index: $e');
      _videoStates[index] = VideoState.error;
      await _cleanupController(index);
    }
  }

  void _updateBufferingState(VideoPlayerController controller, int index) {
    final positions = controller.value.buffered;
    if (positions.isNotEmpty) {
      final lastBufferedPosition = positions.last.end;
      final duration = controller.value.duration;

      if (duration != Duration.zero) {
        final progress =
            lastBufferedPosition.inMilliseconds / duration.inMilliseconds;
        _bufferingProgress[index] = progress;
      }

      // Update video state based on actual playback
      if (controller.value.isPlaying &&
          controller.value.position.inMilliseconds > 0 &&
          !controller.value.isBuffering) {
        _videoStates[index] = VideoState.ready;
      } else if (controller.value.isBuffering) {
        _videoStates[index] = VideoState.buffering;
      }
    }
  }

  Future<void> _checkAndLoadMoreContent(
      VideoPlayerController controller, int index, String url) async {
    if (!controller.value.isInitialized) return;

    final position = controller.value.position;
    final buffered = controller.value.buffered;

    if (buffered.isEmpty) return;

    final lastBuffered = buffered.last.end;
    final duration = controller.value.duration;

    // Start loading next chunk when within 15 seconds of buffer end
    if (position + const Duration(seconds: 15) >= lastBuffered &&
        lastBuffered < duration) {
      // Adaptive chunk size based on network speed and remaining duration
      final remainingDuration = duration - lastBuffered;
      final nextChunkSize = _calculateNextChunkSize(
          remainingDuration.inMilliseconds, _bufferingProgress[index] ?? 0.0);

      final nextChunkStart = lastBuffered.inMilliseconds;
      final nextChunkEnd = nextChunkStart + nextChunkSize;

      try {
        final nextController = VideoPlayerController.network(
          url,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: true,
          ),
          httpHeaders: {
            'Range': 'bytes=$nextChunkStart-$nextChunkEnd',
          },
        );

        await nextController.initialize();

        // Smooth controller transition
        final wasPlaying = controller.value.isPlaying;
        final currentPosition = controller.value.position;

        if (wasPlaying) {
          await controller.pause();
        }

        await _cleanupController(index);
        _controllers[index] = nextController;

        await nextController.seekTo(currentPosition);
        if (wasPlaying) {
          await nextController.play();
        }
      } catch (e) {
        debugPrint('Error loading next chunk: $e');
      }
    }
  }

  int _calculateNextChunkSize(int remainingMs, double currentProgress) {
    // Base chunk size
    const baseChunkSize = 1024 * 512; // 500KB

    // Adjust based on remaining duration
    if (remainingMs < 30000) {
      // Less than 30 seconds remaining
      return baseChunkSize ~/ 2;
    } else if (remainingMs > 300000) {
      // More than 5 minutes remaining
      return baseChunkSize * 2;
    }

    // Adjust based on current loading progress
    if (currentProgress < 0.3) {
      // Slow connection
      return baseChunkSize ~/ 2;
    } else if (currentProgress > 0.8) {
      // Fast connection
      return baseChunkSize * 2;
    }

    return baseChunkSize;
  }

  Future<void> _cleanupController(int index) async {
    final controller = _controllers[index];
    if (controller != null) {
      try {
        await controller.pause();
        await controller.dispose();
      } catch (e) {
        debugPrint('Error disposing controller at index $index: $e');
      }
      _controllers.remove(index);
      _bufferingProgress.remove(index);
    }
  }

  VideoPlayerController? getController(int index) {
    return _videoStates[index] == VideoState.ready ||
            _videoStates[index] == VideoState.buffering
        ? _controllers[index]
        : null;
  }

  Future<void> playVideo(int index) async {
    final controller = _controllers[index];
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.play(); // Ensures video plays after it is initialized
      } catch (e) {
        debugPrint('Error playing video at index $index: $e');
      }
    }
  }

  Future<void> pauseAllExcept(int currentIndex) async {
    for (var entry in _controllers.entries) {
      if (entry.key != currentIndex) {
        try {
          await entry.value.pause();
        } catch (e) {
          debugPrint('Error pausing video at index ${entry.key}: $e');
        }
      }
    }
  }

  Future<void> disposeController(int index) async {
    await _cleanupController(index);
    _videoStates.remove(index);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    for (var index in _controllers.keys.toList()) {
      await _cleanupController(index);
    }
    _videoStates.clear();
  }
}
