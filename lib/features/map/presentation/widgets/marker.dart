import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_lottie.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:lottie/lottie.dart';




class AnimatedLocationMarker extends StatefulWidget {
  final bool isMoving;
  final bool locationNameRetrieved;

  const AnimatedLocationMarker(
      {super.key, required this.isMoving, required this.locationNameRetrieved});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedLocationMarkerState createState() => _AnimatedLocationMarkerState();
}

class _AnimatedLocationMarkerState extends State<AnimatedLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _verticalOffsetAnimation;
  late Animation<double> _shadowScaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _verticalOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -35, end: -47.5).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -47.5, end: -60).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -60, end: -47.5).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 1.0,
      ),
    ]).animate(_animationController);

    _shadowScaleAnimation = Tween<double>(begin: 0.7, end: 0.9).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedLocationMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isMoving != oldWidget.isMoving) {
      if (widget.isMoving) {
        // Ensure the animation restarts completely
        _startContinuousAnimation();
      } else {
        _stopAnimationSmoothly();
      }
    }
  }

  void _startContinuousAnimation() {
    // Reset the animation controller and repeat it from the start.
    _animationController.reset();
    _animationController.forward().then((value) {
      _animationController.repeat(reverse: true);
    });
  }

  void _stopAnimationSmoothly() {
    // Stop animation immediately but return to start position smoothly
    _animationController.stop();
    _animationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 70,
      child: Stack(
        children: [
          // Shadow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _shadowScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _shadowScaleAnimation.value,
                  child: Opacity(
                    opacity: 0.3,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipOval(
                        child: Container(
                          width: 25, // Wider than height for an oval
                          height: 20, // Shorter height for an oval
                          color: Colors.black.withOpacity(0.2), // Oval background color
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _shadowScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _shadowScaleAnimation.value,
                  child: Opacity(
                    opacity: 0.5,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipOval(
                        child: Container(
                            width: 18,
                            height: 13,
                            color: Colors.black.withOpacity(0.2)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _shadowScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _shadowScaleAnimation.value,
                  child: Opacity(
                    opacity: 0.8,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipOval(
                        child: Container(
                            width: 7,
                            height: 5,
                            color: Colors.black.withOpacity(0.2)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Animated Marker
          AnimatedBuilder(
            animation: _verticalOffsetAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _verticalOffsetAnimation.value + 30),
                child: Container(
                  width: 55,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: widget.locationNameRetrieved
                                ? const Icon(
                                    Icons.location_history,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : Lottie.asset(
                                    AppLottie.markerLoader,
                                    repeat: true,
                                    reverse: true,
                                  ),
                          ),
                        ),
                        Container(
                          width: 3, // Width of the line
                          height: 20, // Height of the line
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}