import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  const MainWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.events)) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.push(Routes.post);
        break;
      case 2:
        context.go(Routes.events);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final bool showBottomNav = !location.startsWith(Routes.post);

    return Scaffold(
      extendBody: true,
      body: widget.child,
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
                currentIndex: _calculateSelectedIndex(context),
                onTap: (index) => _onItemTapped(context, index),
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


