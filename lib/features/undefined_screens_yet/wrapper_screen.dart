import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  void _goToBranch(int index) {
    if (index == 1) {
      // Check if we're in home or events section
      if (widget.navigationShell.currentIndex == 0 ||
          widget.navigationShell.currentIndex == 2) {
        context.push(Routes.post);
      }
    } else {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final bool showBottomNav = !location.startsWith(Routes.post);

    return Scaffold(
      extendBody: false,
      body: widget.navigationShell,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                // ignore: deprecated_member_use
                backgroundColor: AppColors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: CupertinoColors.inactiveGray,
                onTap: (index) => _goToBranch(index),
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.plus_circled,
                      size: 30,
                    ),
                    label: 'Add Post',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
