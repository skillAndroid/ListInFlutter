// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  double get _appBarOpacity {
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
                      tabs: const [
                        Tab(
                          child: Text(
                            "Posts",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Products",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Videos",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor:
                          AppColors.primary, // Remove default indicator
                      indicatorWeight: 4,
                    ),
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
                      _buildInfinitePostsGrid(),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      _buildInfiniteProductsGrid(),
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
          _buildFloatingAppBar(),
        ],
      ),
    );
  }

// Update your _buildSliverAppBar method
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: SmoothClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppImages.wHousehold,
                    fit: BoxFit.cover,
                  ),
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
                  _buildProfileHeader(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: _maxAppBarHeight,
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.5),
                ),
                _buildStatItem('19', 'Followers'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

//
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
            AppImages.wPlats,
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
            AppColors.containerColor,
            AppColors.green,
          ),
          _buildActionItem(
            CupertinoIcons.paperplane_fill,
            'Message',
            AppColors.containerColor,
            AppColors.green,
          ),
          _buildActionItem(
            isFollowing ? Ionicons.person_remove : Ionicons.person_add,
            isFollowing ? 'Unfollow' : 'Follow',
            isFollowing ? Colors.grey[200]! : AppColors.containerColor,
            isFollowing ? Colors.grey : AppColors.green,
            onTap: () {
              setState(() {
                isFollowing = !isFollowing;
              });
            },
          ),
          _buildActionItem(
            Ionicons.notifications,
            'Notifications',
            AppColors.containerColor,
            AppColors.green,
          ),
          _buildActionItem(
            Icons.more_horiz,
            'More',
            AppColors.containerColor,
            AppColors.green,
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
    final buttonContent = SmoothClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 70,
        height: 68,
        color: backgroundColor,
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

  Widget _buildMoreButton() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz),
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

  Widget _buildReviewSection() {
    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Card(
        color: AppColors.containerColor,
        elevation: 0,
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

  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              _appBarOpacity > 0.5 ? Brightness.dark : Brightness.light,
        ),
        child: Container(
          height: _minAppBarHeight + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_appBarOpacity),
          ),
          child: Row(
            children: [
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: _appBarOpacity > 0.5
                      ? Colors.white
                      : Colors.black.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      Ionicons.arrow_back,
                      color: _appBarOpacity > 0.5 ? Colors.black : Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              if (_appBarOpacity > 0.5) ...[
                const SizedBox(width: 8),
                Stack(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.wPlats,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Anna Dii',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                _buildMoreButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfinitePostsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
            child: SmoothClipRRect(
              borderRadius: BorderRadius.circular(8),
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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
            child: SmoothClipRRect(
              borderRadius: BorderRadius.circular(12),
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

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
