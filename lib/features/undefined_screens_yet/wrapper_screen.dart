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
  int _selectedIndex = 0;

  void _goToBranch(int index) {
    if (index == 1) {
      if (widget.navigationShell.currentIndex == 0 ||
          widget.navigationShell.currentIndex == 2) {
        context.push(Routes.post);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If user is not on home, go back to home instead of exiting
      setState(() {
        _selectedIndex = 0;
      });
      widget.navigationShell.goBranch(0);
      return false; // Prevent app from closing
    }
    return true; // Allow app to close if already on home
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final bool showBottomNav = !location.startsWith(Routes.post);

    if (_selectedIndex != widget.navigationShell.currentIndex &&
        widget.navigationShell.currentIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = widget.navigationShell.currentIndex;
        });
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button behavior
      child: Scaffold(
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
                    currentIndex: _selectedIndex,
                    onTap: (index) => _goToBranch(index),
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.home, size: 23),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.plus_circled, size: 28),
                        label: 'Add Post',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.person_fill, size: 23),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}