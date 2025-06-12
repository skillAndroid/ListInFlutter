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
    if (index == 2) {
      // Special handling for post button
      context.push(Routes.post);
    } else {
      // Map UI indices to actual branch indices
      final branchIndex = _mapUiIndexToBranchIndex(index);

      setState(() => _selectedIndex = index);
      widget.navigationShell.goBranch(
        branchIndex,
        initialLocation: branchIndex == widget.navigationShell.currentIndex,
      );
    }
  }

  int _mapUiIndexToBranchIndex(int uiIndex) {
    switch (uiIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Video Feeds
      case 3:
        return 3; // Chats
      case 4:
        return 4; // Profile
      default:
        return 0;
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      widget.navigationShell.goBranch(0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _syncSelectedIndex();
    _updateDarkModeState();

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
        bottomNavigationBar: _buildBottomNavBar(backgroundColor, borderColor),
      ),
    );
  }

  void _syncSelectedIndex() {
    if (widget.navigationShell.currentIndex != 2) {
      final uiIndex =
          _mapBranchIndexToUiIndex(widget.navigationShell.currentIndex);
      if (_selectedIndex != uiIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedIndex = uiIndex);
        });
      }
    }
  }

  int _mapBranchIndexToUiIndex(int branchIndex) {
    switch (branchIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 3;
      case 4:
        return 4;
      default:
        return 0;
    }
  }

  void _updateDarkModeState() {
    final currentUrl = GoRouterState.of(context).uri.toString();
    final inVideoFeeds =
        currentUrl.contains(Routes.videosFeed) || _selectedIndex == 1;

    if (inVideoFeeds != _isDarkMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isDarkMode = inVideoFeeds);
        _updateSystemUiOverlayStyle();
      });
    }
  }

  void _updateSystemUiOverlayStyle() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: _isDarkMode
            ? AppColors.black
            : (isDarkTheme ? Colors.black : Colors.white),
        systemNavigationBarIconBrightness:
            (_isDarkMode || isDarkTheme) ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Widget _buildBottomNavBar(Color backgroundColor, Color borderColor) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Ionicons.home_outline, Ionicons.home),
          _buildNavItem(1, Ionicons.videocam_outline, Ionicons.videocam),
          _buildAddPostButton(),
          _buildNavItem(3, Ionicons.chatbubble_ellipses_outline,
              Ionicons.chatbubble_ellipses),
          _buildProfileNavItem(),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _goToBranch(index),
      icon: Icon(
        isSelected ? selectedIcon : icon,
        size: index == 3 || index == 1 ? 28 : 26,
        color: _isDarkMode
            ? AppColors.white.withOpacity(0.8)
            : Theme.of(context).colorScheme.secondary,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildAddPostButton() {
    return IconButton(
      onPressed: () => _goToBranch(2),
      icon: Icon(
        CupertinoIcons.plus,
        size: 32,
        color: _isDarkMode
            ? AppColors.white.withOpacity(0.8)
            : Theme.of(context).colorScheme.secondary,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildProfileNavItem() {
    final isSelected = _selectedIndex == 4;
    final hasProfileImage = AppSession.profileImagePath?.isNotEmpty ?? false;

    return IconButton(
      onPressed: () => _goToBranch(4),
      icon: hasProfileImage
          ? _buildProfileImage(isSelected)
          : _buildProfileIcon(isSelected),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildProfileImage(bool isSelected) {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(
        width: isSelected ? 1.5 : 0,
        color: isSelected
            ? _isDarkMode
                ? AppColors.white.withOpacity(0.8)
                : Theme.of(context).colorScheme.secondary
            : AppColors.transparent,
      ),
      child: SizedBox(
        height: 26.5,
        width: 26.5,
        child: CachedNetworkImage(
          imageUrl: "https://${AppSession.profileImagePath}",
          placeholder: (context, url) => Container(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          errorWidget: (context, url, error) => _buildProfileIcon(isSelected),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileIcon(bool isSelected) {
    return Icon(
      isSelected ? CupertinoIcons.person_fill : CupertinoIcons.person,
      size: 28,
      color: isSelected
          ? Theme.of(context).colorScheme.secondary
          : CupertinoColors.inactiveGray,
    );
  }
}
