// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';

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
                  height: 73,
                  child: BottomNavigationBar(
                    backgroundColor: AppColors.white,
                    selectedItemColor: AppColors.black,
                    unselectedItemColor: CupertinoColors.inactiveGray,
                    currentIndex: _selectedIndex,
                    onTap: (index) => _goToBranch(index),
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    items: [
                      // Home with custom image
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          AppIcons.bg_icon,
                          height: 24,
                          width: 24,
                          color: _selectedIndex == 0
                              ? AppColors.black
                              : CupertinoColors.inactiveGray,
                        ),
                        label: 'Search',
                      ),
                      // Add Post - keeping the original icon
                      const BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.plus_circled, size: 28),
                        label: 'Add Post',
                      ),
                      // Profile with user avatar
                      BottomNavigationBarItem(
                        icon: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: AppSession.profileImageUrl != null &&
                                    AppSession.profileImageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: AppSession.profileImageUrl!,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      CupertinoIcons.person_fill,
                                      size: 23,
                                      color: _selectedIndex == 2
                                          ? AppColors.black
                                          : CupertinoColors.inactiveGray,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    AppImages.appLogo,
                                    height: 24,
                                    width: 24,
                                  ),
                          ),
                        ),
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
