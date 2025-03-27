// ignore_for_file: deprecated_member_use

import 'package:figma_squircle/figma_squircle.dart'
    show SmoothBorderRadius, SmoothRadius;
import 'package:flutter/material.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class RecommendationsRow extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const RecommendationsRow({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return RecommendationCard(item: item);
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final RecommendationItem item;

  const RecommendationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 4, right: 8), // Add bottom padding here
      child: GestureDetector(
        onTap: () => _showBottomSheet(context, item),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                ),
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: Constants.Arial,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, RecommendationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: item.color,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius.only(
          topLeft: SmoothRadius(
            cornerRadius: 28,
            cornerSmoothing: 0.1,
          ),
          topRight: SmoothRadius(
            cornerRadius: 28,
            cornerSmoothing: 0.1,
          ),
        ),
      ),
      builder: (context) => RecommendationBottomSheet(item: item),
    );
  }
}

class RecommendationItem {
  final String title;
  final IconData icon;
  final Color color;

  RecommendationItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class RecommendationBottomSheet extends StatelessWidget {
  final RecommendationItem item;
  const RecommendationBottomSheet({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: 28,
        cornerSmoothing: 0.1,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: item.color,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              item.color,
              item.color.darken(10),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator and spacing
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 32),
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),

            // Title with icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 0.8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Info message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 16,
                  cornerSmoothing: 0.8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "This feature is currently in development",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Button
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 16,
                  cornerSmoothing: 0.8,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to darken colors
extension ColorExtension on Color {
  Color darken(int percent) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }
}

// Widget to apply smooth corner clipping with figma_squircle
class ClipSmoothRect extends StatelessWidget {
  final Widget child;
  final SmoothBorderRadius radius;

  const ClipSmoothRect({
    super.key,
    required this.child,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: SmoothRectangleBorder(
          borderRadius: radius,
        ),
      ),
      child: child,
    );
  }
}
