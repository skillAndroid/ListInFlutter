// ignore_for_file: deprecated_member_use

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
  int _selectedIndex = 0; // Track selected index separately

  void _goToBranch(int index) {
    if (index == 1) {
      // For Add Post tab, don't update selection but push the route
      if (widget.navigationShell.currentIndex == 0 ||
          widget.navigationShell.currentIndex == 2) {
        context.push(Routes.post);
      }
    } else {
      // Update selected index and navigate
      setState(() {
        _selectedIndex = index;
      });
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

    // Update selected index based on navigation shell when component mounts
    // or when the navigation shell's index changes
    if (_selectedIndex != widget.navigationShell.currentIndex &&
        widget.navigationShell.currentIndex != 1) {
      // Ignore Add Post tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = widget.navigationShell.currentIndex;
        });
      });
    }

    return Scaffold(
      extendBody: false,
      body: widget.navigationShell,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                height: 75,
                child: BottomNavigationBar(
                  backgroundColor: AppColors.white,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: CupertinoColors.inactiveGray,
                  currentIndex: _selectedIndex, // Use our tracked index
                  onTap: (index) => _goToBranch(index),
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold font for selected label
                  ),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.home, size: 23,),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        CupertinoIcons.plus_circled,
                        size: 28,
                      ),
                      label: 'Add Post',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person_fill, size: 23,),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
