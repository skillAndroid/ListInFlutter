// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class VisitorProfileScreen extends StatefulWidget {
  final String userId;
  final List<ProductEntity> products; // ID of the profile being viewed
  const VisitorProfileScreen(
      {super.key, required this.userId, required this.products});

  @override
  State<VisitorProfileScreen> createState() => _VisitorProfileScreenState();
}

class _VisitorProfileScreenState extends State<VisitorProfileScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool isFollowing = false;

  double _offset = 0;
  final double _maxAppBarHeight = 180;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _offset = _scrollController.offset;
        });
      });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildContactActions(),
                      _buildReviewSection(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.shopping_cart),
                              SizedBox(width: 8),
                              Text(
                                "Products",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.photo_fill),
                              SizedBox(width: 8),
                              Text(
                                "Posts",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.play_circle_fill),
                              SizedBox(width: 8),
                              Text(
                                "Videos",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.bgColor,
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
              child: TabBarView(
                controller: _tabController,
                children: [
                  CustomScrollView(
                    slivers: [
                      _buildInfiniteProductsGrid(),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      _buildInfinitePostsGrid(),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      _buildInfiniteVideosGrid(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //  _buildFloatingAppBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final double progress = math.min(1.0, _offset / _maxAppBarHeight);
    final Size screenSize = MediaQuery.of(context).size;
    final double topPadding = MediaQuery.of(context).padding.top;

    // Dynamic sizing based on screen width
    final double maxAvatarSize = math.min(125, screenSize.width * 0.3);
    final double minAvatarSize = 40;
    final double avatarSize =
        math.max(minAvatarSize, maxAvatarSize * (1 - progress));

    // Calculate positions
    final double avatarLeftPosition =
        Tween<double>(begin: 16, end: 56).transform(progress);
    final double avatarTopPosition =
        Tween<double>(begin: 50, end: 8).transform(progress);

    final double maxNameWidth = screenSize.width * 0.45;
    final double nameScale =
        Tween<double>(begin: 1.0, end: 0.85).transform(progress);
    final double nameLeftPosition = Tween<double>(
            begin: avatarLeftPosition + maxAvatarSize + 20,
            end: avatarLeftPosition + minAvatarSize + 12)
        .transform(progress);
    final double nameTopPosition =
        Tween<double>(begin: 70, end: 12).transform(progress);

    final double statsOpacity = math.max(0, 1 - (progress * 2));
    final double statsOffset = _offset * 0.3;

    // Adjusted action buttons opacity to appear later
    final double actionOpacity =
        math.max(0, (progress - 0.7) * 3.3); // More delayed appearance

    return SliverAppBar(
      expandedHeight: _maxAppBarHeight,
      pinned: true,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.bgColor.withOpacity(math.max(0, progress)),
      elevation: progress > 0.5 ? 1 : 0,
      automaticallyImplyLeading: false,
      actions: [
        Opacity(
          opacity: actionOpacity,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isFollowing ? Colors.grey.shade200 : AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(80, 32),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      color: isFollowing ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.ellipsis,
                  color: Colors.black,
                  size: 22,
                ),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Share Profile'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Report'),
                        ),
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Block User'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
      flexibleSpace: Stack(
        children: [
          // Back button with original style
          Positioned(
            top: topPadding + 4,
            left: 8,
            child: IconButton(
              icon: const Icon(Ionicons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Avatar
          Positioned(
            left: avatarLeftPosition,
            top: topPadding + avatarTopPosition,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(AppImages.wAuto, fit: BoxFit.cover),
              ),
            ),
          ),

          // Username
          Positioned(
            left: nameLeftPosition,
            top: topPadding + nameTopPosition,
            child: Transform.scale(
              scale: nameScale,
              child: Container(
                constraints: BoxConstraints(maxWidth: maxNameWidth),
                child: const Text(
                  'Anna Dii',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Stats
          Positioned(
            left: nameLeftPosition,
            top: topPadding + 110 - statsOffset,
            child: Opacity(
              opacity: statsOpacity,
              child: Transform.translate(
                offset: Offset(0, -statsOffset),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxNameWidth),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatItem('12', 'Following'),
                      Container(
                        height: 20,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.black,
                      ),
                      _buildStatItem('19', 'Followers'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//
  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

//
  Widget _buildContactActions() {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(
            CupertinoIcons.phone_fill,
            'Call',
            AppColors.white,
            AppColors.myRedBrown,
          ),
          _buildActionItem(
            CupertinoIcons.paperplane_fill,
            'Message',
            AppColors.white,
            AppColors.primary,
          ),
          _buildActionItem(
            isFollowing ? Ionicons.person_remove : Ionicons.person_add,
            isFollowing ? 'Unfollow' : 'Follow',
            isFollowing ? AppColors.white : AppColors.white,
            isFollowing ? Colors.grey : AppColors.darkGray,
            onTap: () {
              setState(() {
                isFollowing = !isFollowing;
              });
            },
          ),
          _buildActionItem(
            Ionicons.notifications,
            'Notifications',
            AppColors.white,
            AppColors.darkGray,
          ),
          _buildActionItem(
            Icons.more_horiz,
            'More',
            AppColors.white,
            AppColors.darkGray,
            isMoreOptions: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color backgroundColor,
    Color iconColor, {
    VoidCallback? onTap,
    bool isMoreOptions = false,
  }) {
    final buttonContent = Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: backgroundColor,
      shadowColor: AppColors.black.withOpacity(0.2),
      child: SizedBox(
        width: 70,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    if (isMoreOptions) {
      return PopupMenuButton(
        child: buttonContent,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'block',
            child: Text('Block User'),
          ),
          const PopupMenuItem(
            value: 'report',
            child: Text('Report'),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Text('Share Profile'),
          ),
        ],
        onSelected: (value) {
          // Handle menu item selection
        },
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: buttonContent,
    );
  }

  Widget _buildReviewSection() {
    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Card(
        color: AppColors.white,
        elevation: 10,
        shadowColor: AppColors.black.withOpacity(0.2),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(right: 20, left: 8, top: 16, bottom: 16),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < 4 ? Icons.star : Icons.star_half,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '(128 reviews)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                width: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                flex: 11,
                child: _buildRecentReviewers(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReviewers() {
    return Padding(
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
    );
  }

  Widget _buildInfinitePostsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // Check if we need to load more data
          if (index >= widget.products.length - 5) {
            // Implement your load more logic here
            // You can call a method to fetch more data
            // loadMorePosts();
          }

          return GestureDetector(
            onTap: () {},
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppImages.wPlats,
                  fit: BoxFit.cover,
                ),
                if (index % 3 == 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: widget.products.length,
      ),
    );
  }

  Widget _buildInfiniteProductsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // Check if we need to load more data
          if (index >= widget.products.length - 4) {
            // Implement your load more logic here
            // loadMoreProducts();
          }

          return GestureDetector(
            onTap: () {},
            child: RegularProductCard(product: widget.products[index]),
          );
        },
        childCount: widget.products.length,
      ),
    );
  }

  Widget _buildInfiniteVideosGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // Check if we need to load more data
          if (index >= widget.products.length - 4) {
            // Implement your load more logic here
            // loadMoreVideos();
          }

          return GestureDetector(
            onTap: () {},
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppImages.wPlats,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '3:45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Random().nextInt(1000)}K views',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        childCount: widget.products.length,
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {this.backgroundColor = Colors.white});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: TabBar(
            controller: tabBar.controller,
            tabs: tabBar.tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            labelPadding: const EdgeInsets.symmetric(vertical: 8),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(10),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 65;

  @override
  double get minExtent => 65;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
