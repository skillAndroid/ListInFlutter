// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  SliverTabBarDelegate(this.tabBar, {this.backgroundColor = Colors.white});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: TabBar(
              padding: EdgeInsets.zero,
              controller: tabBar.controller,
              tabs: tabBar.tabs,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
              labelPadding: const EdgeInsets.symmetric(vertical: 0),
              dividerColor: Colors.transparent,
              overlayColor:
                  MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 0),
            child: Container(
              height: 1, // Height of the bottom grey line
              color:
                  Colors.grey.withOpacity(0.1), // Light grey color for the line
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
