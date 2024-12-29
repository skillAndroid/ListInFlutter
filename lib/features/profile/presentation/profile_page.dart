// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'dart:math' as math;

import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
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
  final double _minAppBarHeight = 80;

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
    // Start showing app bar content after 60% of scroll
    return math.min(
        1,
        math.max(
            0, (_offset - _maxAppBarHeight * 0.6) / (_maxAppBarHeight * 0.4)));
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
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: Container(), // Empty container to preserve space
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with blur
                      Image.asset(
                        AppImages.wAuto,
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
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildReviewSection(),
                    _buildMainContent(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: AppColors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.black.withOpacity(0.2),
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Add your edit logic here
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black.withOpacity(0.2),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2.5),
                    IconButton(
                      onPressed: () {
                        // Add your photo change logic here
                      },
                      icon: const Icon(
                        CupertinoIcons.photo_camera_solid,
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
          elevation: 2,
          child: Container(
            height: _minAppBarHeight,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top,
            ),
            child: Stack(
              children: [
                // Back button
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        CupertinoIcons.back,
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
                  ),
                ),
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
                          // Add your edit logic here
                        },
                        icon: Icon(
                          Icons.edit,
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
                      IconButton(
                        onPressed: () {
                          // Add your photo gallery logic here
                        },
                        icon: Icon(
                          CupertinoIcons.photo_camera_solid,
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
    final avatarSize = math.max(40, 120 - _offset * 0.5);
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return Column(
      children: [
        _buildPremiumCard(),
        const SizedBox(height: 16),
        ...List.generate(
          10,
          (index) => _buildListItem(
            icon: _getIcon(index),
            title: _getTitle(index),
            trailing: _getTrailing(index),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          elevation: 4, // Shadow
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondaryColor, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get exclusive features and benefits',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SmoothClipRRect(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required String icon,
    required String title,
    String? trailing,
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
      onTap: () {},
    );
  }

  String _getIcon(int index) {
    final icons = [
      AppIcons.addsIc,
      AppIcons.favorite,
      AppIcons.chatIc,
      AppIcons.languageIc,
      AppIcons.cardIc, // settings should be
      AppIcons.supportIc,
      AppIcons.supportIc,
      AppIcons.supportIc,
      AppIcons.logoutIc,
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
      'Settings',
      'Help Center',
      'About Us',
      'Contact Support',
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
