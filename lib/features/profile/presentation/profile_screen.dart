// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final List<ProductEntity> products; // ID of the profile being viewed
  const ProfileScreen(
      {super.key, required this.userId, required this.products});

  @override
  State<ProfileScreen> createState() => _VisitorProfileScreenState();
}

class _VisitorProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool isFollowing = false;

  String selectedProductFilter = 'active';

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
                      _buildProductFilters(),
                      _buildFilteredProductsGrid(),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 56,
                            ),
                            Icon(
                              CupertinoIcons.doc_text,
                              size: 76,
                              color: AppColors.grey,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Empty List",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 56,
                            ),
                            Icon(
                              CupertinoIcons.video_camera,
                              size: 76,
                              color: AppColors.grey,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Empty List",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey),
                            )
                          ],
                        ),
                      ),
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

    final bool showEditButtons = progress < 0.3;

    final double maxAvatarSize = math.min(125, screenSize.width * 0.3);
    final double minAvatarSize = 40;
    final double avatarSize =
        math.max(minAvatarSize, maxAvatarSize * (1 - progress));

    final double avatarLeftPosition =
        Tween<double>(begin: 12, end: 28).transform(progress);
    final double avatarTopPosition =
        Tween<double>(begin: 50, end: 8).transform(progress);

    final double maxNameWidth = screenSize.width * 0.45;
    final double nameScale =
        Tween<double>(begin: 1.0, end: 0.85).transform(progress);
    final double nameLeftPosition = Tween<double>(
            begin: avatarLeftPosition + maxAvatarSize + 28,
            end: avatarLeftPosition + minAvatarSize + 4)
        .transform(progress);
    final double nameTopPosition =
        Tween<double>(begin: 70, end: 12).transform(progress);

    final double statsOpacity = math.max(0, 1 - (progress * 2));
    final double statsOffset = _offset * 0.3;

    return SliverAppBar(
      expandedHeight: _maxAppBarHeight,
      pinned: true,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.bgColor.withOpacity(math.max(0, progress)),
      elevation: progress > 0.5 ? 1 : 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(
            Ionicons.ellipsis_horizontal,
            color: Colors.black87, // Changed to black87 for consistency
            size: 22,
          ),
          onPressed: () {
            // Navigate to settings
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: Stack(
        children: [
          // Avatar with edit button
          Positioned(
            left: avatarLeftPosition,
            top: topPadding + avatarTopPosition,
            child: Stack(
              children: [
                Container(
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
                if (showEditButtons)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            Colors.black87, // Changed from primary to black87
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14, // Slightly smaller
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
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
                child: Row(
                  children: [
                    Text(
                      'Anna Dii',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.black87, // Changed from primary to black87
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showEditButtons)
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color:
                              Colors.black54, // Changed from primary to black54
                        ),
                        onPressed: null,
                      ),
                  ],
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
                        color: Colors.black26, // Changed to lighter color
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

  Widget _buildContactActions() {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(
            CupertinoIcons.plus_circle_fill,
            'Create',
            AppColors.white,
            AppColors.primaryDark,
            onTap: () {
              // Handle create action
            },
          ),
          _buildActionItem(
            CupertinoIcons.bell_fill,
            'Alerts',
            AppColors.white,
            AppColors.darkGray,
            onTap: () {
              // Handle notifications
            },
          ),
          _buildActionItem(
            Icons.edit,
            'Edit',
            AppColors.white,
            AppColors.darkGray,
            onTap: () {
              context.goNamed(RoutesByName.profileEdit);
            },
          ),
          _buildActionItem(
            Icons.workspace_premium,
            'Premium',
            AppColors.white,
            AppColors.myRedBrown,
            onTap: () {
              // Handle premium upgrade
            },
          ),
          _buildActionItem(
            Icons.settings,
            'Settings',
            AppColors.white,
            AppColors.darkGray,
            onTap: () {
              // Handle settings
            },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
      ),
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

  Widget _buildProductFilters() {
    return SliverToBoxAdapter(
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 16, left: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip('Active', 'active'),
            _buildFilterChip('In Queue', 'queue'),
            _buildFilterChip('Inactive', 'inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedProductFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        elevation: 0,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(8)),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        side: BorderSide.none,
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedProductFilter = value;
          });
        },
        backgroundColor: AppColors.containerColor,
        selectedColor: AppColors.containerColor,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilteredProductsGrid() {
    // Filter products based on selectedProductFilter
    final List<ProductEntity> filteredProducts =
        widget.products.where((product) {
      switch (selectedProductFilter) {
        case 'active':
          return true; // Assuming all products in the list are active
        case 'queue':
        case 'inactive':
          return false; // For demonstration, showing no products for these filters
        default:
          return true;
      }
    }).toList();

    if (filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
              ),
              Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No $selectedProductFilter products',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Changed to 1 for single column
        crossAxisSpacing: 4,
        mainAxisSpacing: 4, // Slightly increased for better vertical spacing
        childAspectRatio:
            2.8, // Adjusted for horizontal card (width/height ratio)
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child:
                HorizontalProfileProductCard(product: filteredProducts[index]),
          );
        },
        childCount: filteredProducts.length,
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
