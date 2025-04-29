// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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
  bool _isDarkMode = false;

  void _goToBranch(int index) {
    if (index == 1) {
      // Special handling for post button - push route instead of changing branch
      if (widget.navigationShell.currentIndex == 0 ||
          widget.navigationShell.currentIndex == 2 ||
          widget.navigationShell.currentIndex == 3) {
        context.push(Routes.post);
      }
    } else {
      // For home, chats, and profile - navigate to the correct branch
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
      // If user is not on home (including chats or profile), go back to home instead of exiting
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
    // Sync _selectedIndex with navigationShell.currentIndex to handle navigation via other means
    if (_selectedIndex != widget.navigationShell.currentIndex &&
        widget.navigationShell.currentIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = widget.navigationShell.currentIndex;
        });
      });
    }

    // Get the current URL using your suggested approach
    final String currentUrl = GoRouterState.of(context).uri.toString();

    // Check if we're in video feeds
    final bool inVideoFeeds = currentUrl.contains(Routes.videosFeed);

    // Update dark mode state if needed
    if (inVideoFeeds != _isDarkMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isDarkMode = inVideoFeeds;
        });
        // Set system navigation bar style
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor:
                _isDarkMode ? AppColors.black : Colors.white,
            systemNavigationBarIconBrightness:
                _isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
      });
    }

    // Define colors based on mode
    final backgroundColor = _isDarkMode
        ? AppColors.black
        : Theme.of(context).scaffoldBackgroundColor;
    final borderColor = _isDarkMode
        ? Colors.grey[800] ?? AppColors.containerColor
        : Theme.of(context).colorScheme.onSecondary;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          height: 47,
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color:
                    _isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.1),
                blurRadius: 2,
                offset: Offset(0, -1), // Shadow positioned at the top
                spreadRadius: 0.3,
              ),
            ],
            border: Border(
              top: BorderSide(
                color: borderColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                Ionicons.home_outline,
                Ionicons.home,
              ),
              _buildAddPostButton(),
              _buildNavItem(
                2,
                Ionicons.chatbubble_ellipses_outline,
                Ionicons.chatbubble_ellipses,
              ),
              _buildProfileNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _goToBranch(index),
      icon: Icon(
        isSelected ? selectedIcon : icon,
        size: index == 2 ? 26 : 24,
        color: _isDarkMode
            ? AppColors.white
            : Theme.of(context).colorScheme.secondary,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildAddPostButton() {
    return IconButton(
      onPressed: () => _goToBranch(1),
      icon: Icon(CupertinoIcons.plus,
          size: 30,
          color: _isDarkMode
              ? AppColors.white
              : Theme.of(context).colorScheme.secondary),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildProfileNavItem() {
    bool isSelected = _selectedIndex == 3;
    return IconButton(
      onPressed: () =>
          _goToBranch(3), // This will navigate to profile branch (index 3)
      icon: AppSession.profileImagePath != null &&
              AppSession.profileImagePath!.isNotEmpty
          ? SmoothClipRRect(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                width: isSelected ? 1.5 : 0,
                color: isSelected
                    ? _isDarkMode
                        ? AppColors.white
                        : Theme.of(context).colorScheme.secondary
                    : AppColors.transparent,
              ),
              child: SizedBox(
                height: 24.5,
                width: 24.5,
                child: CachedNetworkImage(
                  imageUrl: "https://${AppSession.profileImagePath}",
                  placeholder: (context, url) => Container(
                    color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Icon(
                    isSelected
                        ? CupertinoIcons.person_fill
                        : CupertinoIcons.person,
                    size: 26,
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : CupertinoColors.inactiveGray,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Icon(
              isSelected ? CupertinoIcons.person_fill : CupertinoIcons.person,
              size: 26,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : CupertinoColors.inactiveGray,
            ),
      padding: EdgeInsets.zero,
    );
  }
}
