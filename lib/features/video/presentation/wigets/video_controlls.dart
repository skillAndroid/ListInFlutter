// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 6,
      right: 6,
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
              // Wrap with Expanded
              child: SizedBox(
                // Add Container for height constraint

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomVideoProgressIndicator(
                      widget.controller,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    )
                  ],
                ),
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
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
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
