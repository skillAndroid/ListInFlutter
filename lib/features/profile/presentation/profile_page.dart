// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _AnimatedProfileScreenState();
}

class _AnimatedProfileScreenState extends State<ProfileScreen> {
  late ScrollController _scrollController;

  double _offset = 0;
  final double _maxAppBarHeight = 300;
  final double _minAppBarHeight = 60;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _offset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double get _appBarOpacity {
    // Start showing app bar content after 40% of scroll instead of 60%
    return math.min(
        1,
        math.max(
            0, (_offset - _maxAppBarHeight * 0.4) / (_maxAppBarHeight * 0.3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: _maxAppBarHeight,
                toolbarHeight: _minAppBarHeight,
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: Container(), // Empty container to preserve space
                flexibleSpace: SmoothClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  child: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          AppImages.wHousehold,
                          fit: BoxFit.cover,
                        ),
                        // Blur overlay
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Profile content
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 300,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildAnimatedAvatar(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Anna Dii',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStatItem('12', 'Following'),
                                    Container(
                                      height: 20,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    _buildStatItem('19', 'Followers'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildReviewSection(),
                    _buildMainContent(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Add your edit logic here
                      },
                      icon: const Icon(
                        CupertinoIcons.square_grid_2x2_fill,
                        color: AppColors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black.withOpacity(0.2),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildInteractiveAppBar(),
          ),
        ],
      ),
    );
  }

  void _showIOSMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Profile Settings',
          style: TextStyle(fontFamily: "Syne"),
        ),
        message: const Text(
          'Manage your profile',
          style: TextStyle(fontFamily: "Syne"),
        ),
        actions: [
          // Profile & Account Management
          _buildActionSheetItem(
            icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
            title: 'Edit Profile',
            onPressed: () {
              Navigator.pop(context);
              // Handle edit profile
            },
          ),
          _buildActionSheetItem(
            icon: CupertinoIcons.camera_fill,
            title: 'Change Profile Photo',
            onPressed: () {
              Navigator.pop(context);
              // Handle photo change
            },
          ),
          _buildActionSheetItem(
            icon: CupertinoIcons.time,
            title: 'Working Hours',
            subtitle: '9:00 - 17:00',
            onPressed: () {
              Navigator.pop(context);
              // Handle working hours
            },
          ),
          _buildActionSheetItem(
            icon: CupertinoIcons.moon_fill,
            title: 'Theme',
            subtitle: 'Light',
            onPressed: () {
              Navigator.pop(context);
              // Handle theme change
            },
          ),
          // Logout (Destructive Action)
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.square_arrow_right),
                SizedBox(width: 10),
                Text('Logout',
                    style: TextStyle(fontSize: 18, fontFamily: "Syne")),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
                color: AppColors.black, fontSize: 18, fontFamily: "Syne"),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSheetItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onPressed,
  }) {
    return CupertinoActionSheetAction(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with container
            SmoothClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: "Syne",
                  color: AppColors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Subtitle if provided
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 15,
                  fontFamily: "Syne",
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],

            // Arrow icon
            Icon(
              Ionicons.arrow_forward,
              color: AppColors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveAppBar() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        top: false,
        child: Card(
          color: Colors.white.withOpacity(_appBarOpacity),
          shadowColor: AppColors.grey.withOpacity(_appBarOpacity),
          margin: EdgeInsets.zero,
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 1,
          child: Container(
            height: _minAppBarHeight + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top,
            ),
            child: Stack(
              children: [
                // Animated profile info (keep as is)
                Positioned.fill(
                  child: Opacity(
                    opacity: _appBarOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppImages.appLogo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Anna Dii',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Action buttons
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showIOSMenu(context);
                        },
                        icon: Icon(
                          CupertinoIcons.square_grid_2x2_fill,
                          color: Colors.black.withOpacity(_appBarOpacity),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.grey.withOpacity(0.1 * _appBarOpacity),
                          shape: SmoothRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    final avatarSize = math.max(40, 120 - _offset * 0.7);
    final scale = math.max(0.0, 1 - _offset / 300);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: avatarSize.toDouble(),
        height: avatarSize.toDouble(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            AppImages.wPlats, // Replace with your image
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Card(
        color: AppColors.containerColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Rating Section
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < 4 ? Icons.star : Icons.star_half,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on 128 reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical Divider
              Container(
                height: 60,
                width: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              // Recent Reviewers Section
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: Stack(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Positioned(
                                left: i * 25.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      'https://picsum.photos/200?random=$i',
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 85,
                              top: 8,
                              child: Text(
                                '+25 more',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        const SizedBox(height: 16),
        ...List.generate(
          8,
          (index) => _buildListItem(
            icon: _getIcon(index),
            title: _getTitle(index),
            trailing: _getTrailing(index),
            onTap: () {
              if (index == 0) {
                context.goNamed(RoutesByName.myPosts);
              }
            },
          ),
        ),
        SizedBox(height: screenHeight / 9),
      ],
    );
  }

  Widget _buildListItem({
    required String icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Image.asset(
              icon,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            )
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
      onTap: onTap,
    );
  }

  String _getIcon(int index) {
    final icons = [
      AppIcons.addsIc,
      AppIcons.favorite,
      AppIcons.chatIc,
      AppIcons.cardIc,
      AppIcons.languageIc,
      AppIcons.supportIc,
      AppIcons.personIc,
      AppIcons.logoutIc,
    ];
    return icons[index];
  }

  String _getTitle(int index) {
    final titles = [
      'My Ads',
      'My Favorites',
      'Chats',
      'My Balance',
      'Language',
      'Help Center',
      'About Us',
      'Log Out',
    ];
    return titles[index];
  }

  String? _getTrailing(int index) {
    switch (index) {
      case 0:
        return '5 active';
      case 2:
        return '3 unread';
      case 3:
        return '\$33';
      case 4:
        return 'English';
      default:
        return null;
    }
  }
}
//
