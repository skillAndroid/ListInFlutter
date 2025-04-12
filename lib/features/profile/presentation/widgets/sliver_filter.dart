import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverFiller extends StatelessWidget {
  final Color color;

  const SliverFiller({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        // Get the app bar's height that's visible
        final topPadding = MediaQuery.of(context).padding.top;
        final statusBarHeight = topPadding;
        final appBarHeight = 56.0; // Your app bar height
// Your tab bar height

        // Calculate if there's any gap to fill
        final maxOverlap = statusBarHeight + appBarHeight;
        final visibleOverlap = constraints.overlap;
        final remaining =
            (maxOverlap - visibleOverlap).clamp(0.0, double.infinity);

        // Only show if there's space to fill
        if (remaining > 0) {
          return SliverToBoxAdapter(
            child: Container(
              color: color,
              height: remaining,
            ),
          );
        } else {
          return SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }
}
