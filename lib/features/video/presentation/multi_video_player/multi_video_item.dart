// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/video/presentation/multi_video_player/multi_video_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class MultiVideoItem extends StatefulWidget {
  final AdvertisedProductEntity videoSource;
  final int index;
  final Function(VideoPlayerController controller) onInit;
  final Function(int index) onDispose;
  final VideoPlayerOptions? videoPlayerOptions;
  final VideoSource sourceType;
  final Future<ClosedCaptionFile>? closedCaptionFile;
  final Map<String, String>? httpHeaders;
  final VideoFormat? formatHint;
  final String? package;
  final bool showControlsOverlay;
  final bool showVideoProgressIndicator;
  final VoidCallback onProductTap;

  // ignore: use_super_parameters
  const MultiVideoItem({
    Key? key,
    required this.videoSource,
    required this.index,
    required this.onInit,
    required this.onDispose,
    this.videoPlayerOptions,
    required this.sourceType,
    this.closedCaptionFile,
    this.httpHeaders,
    this.formatHint,
    this.package,
    this.showControlsOverlay = true,
    this.showVideoProgressIndicator = true,
    required this.onProductTap,
  }) : super(key: key);

  @override
  State<MultiVideoItem> createState() => _MultiVideoItemState();
}

class _MultiVideoItemState extends State<MultiVideoItem> {
  late VideoPlayerController _controller;
  bool isLoading = true;
  bool _isDisposed = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _playbackTimer?.cancel();
      _controller = VideoPlayerController.network(
        widget.videoSource.videoUrl,
        videoPlayerOptions: widget.videoPlayerOptions,
        closedCaptionFile: widget.closedCaptionFile,
        httpHeaders: widget.httpHeaders ?? {},
        formatHint: widget.formatHint,
      );

      _controller.addListener(_videoListener);

      await _controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint(
              'Video initialization timeout: ${widget.videoSource.videoUrl}');
          throw TimeoutException('Video initialization timeout');
        },
      );

      if (_isDisposed) {
        await _cleanupResources();
        return;
      }

      widget.onInit.call(_controller);

      if (widget.index == MultiVideo.currentIndex) {
        _playbackTimer = Timer(const Duration(milliseconds: 300), () {
          if (!_isDisposed && mounted) {
            _controller.play();
          }
        });
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      await _cleanupResources();
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _cleanupResources() async {
    _playbackTimer?.cancel();
    if (_controller.value.isInitialized) {
      await _controller.pause();
    }
    await _controller.dispose();
  }

  void _videoListener() {
    if (_isDisposed || !mounted) return;

    if (_controller.value.hasError) {
      debugPrint('Video playback error: ${_controller.value.errorDescription}');
      _cleanupResources();
      return;
    }

    if (widget.index != MultiVideo.currentIndex) {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        }else{
          _controller.play();
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video thumbnail or loading placeholder
            if (widget.videoSource.thumbnailUrl.isNotEmpty == true)
              Image.network(
                widget.videoSource.thumbnailUrl,
                fit: BoxFit.cover,
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
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),

            // Video player
            if (_controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),

            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                  icon: const Icon(Ionicons.close, color: Colors.white),
                  onPressed: () => context.pop()),
            ),

            if (_controller.value.isBuffering || isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Colors.white,
                  ),
                ),
              ),

            // Product info and navigation
            Positioned(
              left: 24,
              right: 24,
              bottom: 64,
              child: GestureDetector(
                onTap: widget.onProductTap,
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
                            height: 84,
                            child: CachedNetworkImage(
                              imageUrl: widget.videoSource.images[0],
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
                              widget.videoSource.price,
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
                              widget.videoSource.title,
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
                                  widget.videoSource.userName,
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
                                  widget.videoSource.userRating.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.black,
                                  ),
                                ),
                                Text(
                                  "(${widget.videoSource.reviewsCount})",
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

            // Video controls
            if (_controller.value.isInitialized) ...[
              if (widget.showControlsOverlay)
                _ControlsOverlay(controller: _controller),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playbackTimer?.cancel();
    _controller.removeListener(_videoListener);
    _cleanupResources();
    widget.onDispose.call(widget.index);
    super.dispose();
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Play/Pause button
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                widget.controller.value.isPlaying
                    ? CupertinoIcons.pause_solid
                    : CupertinoIcons.play_arrow_solid,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                });
              },
            ),

            // Current position
            Text(
              _formatDuration(widget.controller.value.position),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),

            const SizedBox(width: 16),

            // Progress bar with loading indicator
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SmoothClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Expanded(
                      child: CustomVideoProgressIndicator(
                        widget.controller,
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Total duration
            Text(
              _formatDuration(widget.controller.value.duration),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),

            // Volume button
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                widget.controller.value.volume > 0
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  widget.controller.setVolume(
                    widget.controller.value.volume > 0 ? 0 : 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;

  const CustomVideoProgressIndicator(
    this.controller, {
    super.key,
    this.colors = const VideoProgressColors(),
  });

  @override
  State<CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator> {
  _CustomVideoProgressIndicatorState() {
    listener = () {
      if (mounted) setState(() {});
    };
  }

  late VoidCallback listener;
  bool _controllerWasPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double progressBarWidth = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            if (widget.controller.value.isPlaying) {
              _controllerWasPlaying = true;
              widget.controller.pause();
            }
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            final box = context.findRenderObject() as RenderBox;
            final Offset localPosition =
                box.globalToLocal(details.globalPosition);
            final double position =
                localPosition.dx.clamp(0, progressBarWidth) / progressBarWidth;
            widget.controller.seekTo(Duration(
              milliseconds:
                  (widget.controller.value.duration.inMilliseconds * position)
                      .round(),
            ));
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_controllerWasPlaying) {
              widget.controller.play();
              _controllerWasPlaying = false;
            }
          },
          onTapDown: (TapDownDetails details) {
            final box = context.findRenderObject() as RenderBox;
            final Offset localPosition =
                box.globalToLocal(details.globalPosition);
            final double position =
                localPosition.dx.clamp(0, progressBarWidth) / progressBarWidth;
            widget.controller.seekTo(Duration(
              milliseconds:
                  (widget.controller.value.duration.inMilliseconds * position)
                      .round(),
            ));
          },
          child: SizedBox(
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.5),
                  child: LinearProgressIndicator(
                    value: widget.controller.value.isInitialized
                        ? widget.controller.value.position.inMilliseconds /
                            widget.controller.value.duration.inMilliseconds
                        : 0.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        widget.colors.playedColor),
                    backgroundColor: widget.colors.backgroundColor,
                  ),
                ),

                if (widget.controller.value.isInitialized)
                  Positioned(
                    left: (widget.controller.value.position.inMilliseconds /
                            widget.controller.value.duration.inMilliseconds) *
                        (progressBarWidth -
                            16), // Subtract thumb width to prevent overflow
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
