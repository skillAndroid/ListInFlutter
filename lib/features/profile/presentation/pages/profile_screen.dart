// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  void _navigateToEdit(UserProfileEntity userData) {
    context.pushNamed(
      RoutesByName.profileEdit,
      extra: userData,
    );
  }

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

    context.read<UserProfileBloc>().add(GetUserData());
    context.read<UserPublicationsBloc>().add(FetchUserPublications());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      builder: (context, state) {
        if (state.status == UserProfileStatus.loading &&
            state.userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userData = state.userData;
        return Scaffold(
          backgroundColor: AppColors.containerColor,
          body: Stack(
            children: [
              NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverAppBar(userData),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildContactActions(userData),
                          _buildReviewSection(userData),
                          const SizedBox(height: 4),
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
                                  Icon(Icons.inventory),
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
                  padding: const EdgeInsets.only(top: 0, right: 8, left: 8),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Products Tab
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          // Check if we're near the bottom
                          if (scrollInfo is ScrollEndNotification) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent * 0.7) {
                              final publicationsState =
                                  context.read<UserPublicationsBloc>().state;
                              if (!publicationsState.hasReachedEnd &&
                                  !publicationsState.isLoading) {
                                context
                                    .read<UserPublicationsBloc>()
                                    .add(LoadMoreUserPublications());
                              }
                            }
                          }
                          return true;
                        },
                        child: CustomScrollView(
                          slivers: [
                            _buildProductFilters(),
                            _buildFilteredProductsGrid(),
                          ],
                        ),
                      ),
                      // Posts Tab
                      _buildEmptyTab(
                        icon: CupertinoIcons.doc_text,
                        text: "Empty List",
                      ),
                      // Videos Tab
                      _buildEmptyTab(
                        icon: CupertinoIcons.video_camera,
                        text: "Empty List",
                      ),
                    ],
                  ),
                ),
              ),
              //  _buildFloatingAppBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(UserDataEntity? userData) {
    final double progress = math.min(1.0, _offset / _maxAppBarHeight);
    final Size screenSize = MediaQuery.of(context).size;
    final double topPadding = MediaQuery.of(context).padding.top;

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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: userData?.profileImagePath != null
                        ? CachedNetworkImage(
                            imageUrl: 'https://${userData!.profileImagePath!}',
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(
                              AppImages.appLogo,
                              fit: BoxFit.cover,
                            ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                          )
                        : Image.asset(AppImages.appLogo, fit: BoxFit.cover),
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
                      userData?.nickName ?? 'User',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.black87, // Changed from primary to black87
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

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

  Widget _buildContactActions(UserDataEntity? user) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(
            CupertinoIcons.plus_circle_fill,
            'Create',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle create action
            },
          ),
          _buildActionItem(
            CupertinoIcons.bell_fill,
            'Alerts',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle notifications
            },
          ),
          _buildActionItem(
            Icons.edit,
            'Edit',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              _navigateToEdit(UserProfileEntity(
                isBusinessAccount: user?.role != "INDIVIDUAL_SELLER",
                locationName: user?.locationName,
                longitude: user?.longitude,
                latitude: user?.latitude,
                fromTime: user?.fromTime,
                toTime: user?.toTime,
                isGrantedForPreciseLocation: user?.isGrantedForPreciseLocation,
                nickName: user?.nickName,
                phoneNumber: user?.phoneNumber,
                profileImagePath: user?.profileImagePath,
              ));
            },
          ),
          _buildActionItem(
            Icons.workspace_premium,
            'Premium',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle premium upgrade
            },
          ),
          _buildActionItem(
            Icons.settings,
            'Settings',
            AppColors.primaryLight,
            AppColors.black,
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
        elevation: 2,
        shadowColor: Colors.white.withOpacity(0.5),
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.white,
        child: SizedBox(
          width: 70,
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection(UserDataEntity? userData) {
    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Card(
        color: AppColors.white,
        elevation: 1,
        shadowColor: Colors.white.withOpacity(0.5),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(right: 20, left: 4, top: 16, bottom: 16),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData?.rating.toString() ?? "0",
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
            'Reviews',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                for (var i = 0; i < 3; i++)
                  Positioned(
                    left: i * 22.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/200?random=$i',
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 88,
                  top: 10,
                  child: Text(
                    '+25 more',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w700,
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
        shadowColor: AppColors.primary.withOpacity(0.01),
        shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.white, width: 2)),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
          ),
        ),
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
    return BlocConsumer<UserPublicationsBloc, UserPublicationsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if ((state.isLoading || state.isInitialLoading) &&
            state.publications.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
                child: Transform.scale(
              scale: 0.75,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: AppColors.green,
                strokeCap: StrokeCap.round,
              ),
            )),
          );
        }

        if (state.error != null) {
          return SliverToBoxAdapter(
            child: Center(
                child: TextButton(
                    onPressed: () {
                      context
                          .read<UserPublicationsBloc>()
                          .add(FetchUserPublications());
                    },
                    child: Text("Retry"))),
          );
        }

        if (state.publications.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Icon(Icons.inventory, size: 72, color: Colors.grey[400]),
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

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == state.publications.length) {
                if (state.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return null;
              }

              final publication = state.publications[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: HorizontalProfileProductCard(
                  product: publication,
                ),
              );
            },
            childCount: state.publications.length + (state.isLoading ? 1 : 0),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTab({required IconData icon, required String text}) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 56),
              Icon(icon, size: 76, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              )
            ],
          ),
        ),
      ],
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
        color: AppColors.containerColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: TabBar(
            padding: EdgeInsets.all(4),
            controller: tabBar.controller,
            tabs: tabBar.tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            labelPadding: const EdgeInsets.symmetric(vertical: 8),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(15),
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
