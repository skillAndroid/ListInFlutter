// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:list_in/global/likeds/liked_publications_state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  void _navigateToEdit(UserProfileEntity userData) {
    context.pushNamed(
      RoutesByName.profileEdit,
      extra: userData,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);

    context.read<UserProfileBloc>().add(GetUserData());
    context.read<UserPublicationsBloc>().add(FetchUserPublications());
    context.read<LikedPublicationsBloc>().add(FetchLikedPublications());
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
          return Scaffold(body: Progress());
        }
        final userData = state.userData;
        // Add null check validation to prevent null UI
        if (userData == null) {
          return const Scaffold(
              body: Center(child: Text('No user data available')));
        }
        if (state.userData == null) {}

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.bgColor,
            body: NestedScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    snap: false,
                    toolbarHeight: 56,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    scrolledUnderElevation: 0,
                    title: Row(
                      children: [
                        Text(
                          'My Store',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.store_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.black87,
                          size: 24,
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(48, 48),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First row: Image, Name and Role
                          Row(
                            
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile image
                              SizedBox(
                                width: 75,
                                height: 75,
                                child: Stack(
                                  children: [
                                    SmoothClipRRect(
                                      smoothness: 0.8,
                                      borderRadius: BorderRadius.circular(22),
                                      child: userData.profileImagePath != null
                                          ? CachedNetworkImage(
                                              width: double.infinity,
                                              height: double.infinity,
                                              imageUrl:
                                                  'https://${userData.profileImagePath!}',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Progress(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                          AppImages.appLogo),
                                            )
                                          : Image.asset(AppImages.appLogo),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Transform.translate(
                                        offset: Offset(6, 6),
                                        child: SmoothClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: InkWell(
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              color: AppColors.blue,
                                              child: Center(
                                                child: Icon(
                                                  size: 16,
                                                  Icons.add_rounded,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 36),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    _buildStatItem(
                                      userData.rating.toString() == "null"
                                          ? '0'
                                          : userData.rating
                                              .toInt()
                                              .toString(),
                                      'Rating',
                                    ),
                                    const SizedBox(width: 32),
                                    _buildStatItem(
                                        userData.followers.toString(),
                                        'Followers'),
                                    const SizedBox(width: 32),
                                    _buildStatItem(
                                        userData.following.toString(),
                                        'Following'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                userData.nickName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                width: 2,
                                height: 14,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                userData.role,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              userData.biography ?? AppLocalizations.of(context)!.no_biography,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12.5,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.grey[800],
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
                        _buildContactActions(userData),
                        // _buildReviewSection(userData),
                        const SizedBox(height: 12),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_rounded,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.posts,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.reviews,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.heart_circle,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Liked Posts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                        labelColor: AppColors.black,
                        unselectedLabelColor: AppColors.grey,
                        indicator: const CustomLineIndicator(
                          lineHeight: 3,
                          lineWidth: 18, // Reduced from 20
                          color: AppColors.black,
                        ),
                      ),
                      backgroundColor: AppColors.bgColor,
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: Padding(
                padding: const EdgeInsets.only(top: 0, right: 8, left: 4),
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
                          //   _buildProductFilters(),
                          _buildFilteredProductsGrid(),
                        ],
                      ),
                    ),
                    // Posts Tab
          
                    _buildEmptyTab(
                      icon: CupertinoIcons.star,
                      text: "No Reviews",
                    ),
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollEndNotification) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent * 0.7) {
                            final likedPublicationsState =
                                context.read<LikedPublicationsBloc>().state;
                            if (!likedPublicationsState.hasReachedEnd &&
                                !likedPublicationsState.isLoading) {
                              context
                                  .read<LikedPublicationsBloc>()
                                  .add(LoadMoreLikedPublications());
                            }
                          }
                        }
                        return true;
                      },
                      child: CustomScrollView(
                        slivers: [
                          _buildLikedPublicationsGrid(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildContactActions(UserDataEntity? user) {
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionItem(
            0,
            CupertinoIcons.plus,
            'Create',
            AppColors.white,
            AppColors.blue,
            onTap: () {
              context.push(Routes.post);
            },
          ),
          _buildActionItem(
            1,
            CupertinoIcons.bell_fill,
            'Alerts',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle notifications
            },
          ),
          _buildActionItem(
            2,
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
            3,
            Icons.workspace_premium,
            'Premium',
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle premium upgrade
            },
          ),
          _buildActionItem(
            4,
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
    int index,
    IconData icon,
    String label,
    Color backgroundColor,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (index == 0) SizedBox(height: 2),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shadowColor: Colors.white.withOpacity(0.5),
            shape: SmoothRectangleBorder(
                side: BorderSide(
                  width: index == 0 ? 1.5 : 0,
                  color: index == 0
                      ? AppColors.containerColor
                      : AppColors.transparent,
                ),
                borderRadius: index != 0
                    ? BorderRadius.circular(20)
                    : BorderRadius.circular(20)),
            color: index == 0 ? AppColors.white : AppColors.containerColor,
            child: Container(
              margin: index != 0 ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
              width: 56,
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.black,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: index != 0 ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredProductsGrid() {
    return BlocConsumer<UserPublicationsBloc, UserPublicationsState>(
      listener: (context, state) {
        if (state.error != null) {
          _showErrorSnackbar(context, state.error!);
        }
      },
      builder: (context, state) {
        // Loading state
        if ((state.isLoading || state.isInitialLoading) &&
            state.publications.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Progress(),
            ),
          );
        }

        // Error state
        if (state.error != null && state.publications.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FilledButton.icon(
                onPressed: () {
                  context
                      .read<UserPublicationsBloc>()
                      .add(FetchUserPublications());
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ),
          );
        }

        // Empty state - check if we deleted everything
        if (state.publications.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[600],
                    ),
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
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context
                          .read<UserPublicationsBloc>()
                          .add(RefreshUserPublications());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        // Content state with grid
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Display loading indicator at the end if more content is loading
                if (index >= state.publications.length) {
                  if (state.isLoading) {
                    return const Center(child: Progress());
                  }
                  return null;
                }

                final publication = state.publications[index];
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: ProfileProductCard(
                    product: publication,
                  ),
                );
              },
              childCount: state.publications.length + (state.isLoading ? 1 : 0),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikedPublicationsGrid() {
    return BlocConsumer<LikedPublicationsBloc, LikedPublicationsState>(
      listener: (context, state) {
        if (state.error != null) {
          _showErrorSnackbar(context, state.error!);
        }
      },
      builder: (context, state) {
        

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.publications.length) {
                  if (state.isLoading) {
                    return const Center(child: Progress());
                  }
                  return null;
                }

                final publication = state.publications[index];
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: ProductCardContainer(
                    key: ValueKey(
                        publication.id), // Add key for better list updates
                    product: publication,
                  ),
                );
              },
              childCount: state.publications.length + (state.isLoading ? 1 : 0),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
          ),
        );
      },
    );
  }

// Helper method for showing errors
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String text,
    String? subText, // Optional subtitle for more context
  }) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomLineIndicator extends Decoration {
  final double lineHeight;
  final double lineWidth;
  final Color color;

  const CustomLineIndicator({
    this.lineHeight = 2.0,
    this.lineWidth = 20.0,
    this.color = Colors.black,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomLinePainter(
      lineHeight: lineHeight,
      lineWidth: lineWidth,
      color: color,
      onChange: onChanged,
    );
  }
}

class _CustomLinePainter extends BoxPainter {
  final double lineHeight;
  final double lineWidth;
  final Color color;

  _CustomLinePainter({
    required this.lineHeight,
    required this.lineWidth,
    required this.color,
    VoidCallback? onChange,
  }) : super(onChange);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Offset center = Offset(
      offset.dx + configuration.size!.width / 2,
      offset.dy + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: lineWidth,
            height: lineHeight,
          ),
          Radius.circular(1)),
      paint,
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
      color: Colors.white,
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0, 0),
            child: Container(
              height: 1, // Height of the bottom grey line
              color:
                  Colors.grey.withOpacity(0.1), // Light grey color for the line
            ),
          ),
          Expanded(
            child: TabBar(
              padding: EdgeInsets.zero,
              controller: tabBar.controller,
              tabs: tabBar.tabs,
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.grey,
              indicator: const CustomLineIndicator(
                lineHeight: 3.5,
                lineWidth: 20,
                color: Colors.black,
              ),
              labelPadding: const EdgeInsets.symmetric(vertical: 16),
              dividerColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 61;

  @override
  double get minExtent => 61;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
