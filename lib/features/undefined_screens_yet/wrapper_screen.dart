// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      });
    }

    // Define colors based on mode
    final backgroundColor = _isDarkMode ? AppColors.black : AppColors.white;
    final borderColor = _isDarkMode
        ? Colors.grey[800] ?? AppColors.containerColor
        : AppColors.containerColor;
    final textColor = _isDarkMode ? AppColors.white : AppColors.black;
    final inactiveColor = _isDarkMode
        ? Colors.grey[600] ?? CupertinoColors.inactiveGray
        : CupertinoColors.inactiveGray;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          height: 65,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: borderColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNavItem(
                0,
                AppLocalizations.of(context)!.search,
                AppIcons.bg_icon,
                textColor,
                inactiveColor,
              ),
              _buildAddPostButton(textColor, inactiveColor),
              _buildProfileItem(textColor, inactiveColor),
            ],
          ),
        ),
      ),
    );
  }

  // Updated to pass colors
  Widget _buildNavItem(
    int index,
    String label,
    String iconAsset,
    Color activeColor,
    Color inactiveColor,
  ) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _goToBranch(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              height: 24,
              width: 24,
              color: isSelected ? Colors.green : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to pass colors
  Widget _buildAddPostButton(Color activeColor, Color inactiveColor) {
    return InkWell(
      onTap: () => _goToBranch(1),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.plus_circled,
              size: 28,
              color: inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.add_post,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                color: _selectedIndex == 1 ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to pass colors
  Widget _buildProfileItem(Color activeColor, Color inactiveColor) {
    bool isSelected = _selectedIndex == 2;
    return InkWell(
      onTap: () => _goToBranch(2),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: 24,
                width: 24,
                child: AppSession.profileImagePath != null &&
                        AppSession.profileImagePath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: "https://${AppSession.profileImagePath}",
                        placeholder: (context, url) => Container(
                          color:
                              _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Icon(
                          CupertinoIcons.person_fill,
                          size: 23,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Ionicons.person_circle,
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.profile,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
