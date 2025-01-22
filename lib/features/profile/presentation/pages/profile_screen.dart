// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    _tabController = TabController(length: 5, vsync: this);

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
          return Scaffold(
            body: Center(
              child: Transform.scale(
                scale: 0.75,
                child: CircularProgressIndicator(
                  color: AppColors.black,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 7.5,
                ),
              ),
            ),
          );
        }
        final userData = state.userData;
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
                    pinned: true,
                    snap: false,
                    elevation: 0,
                    scrolledUnderElevation: 0.3,
                    shadowColor: AppColors.black,
                    backgroundColor: Colors.white,
                    title: Row(
                      children: [
                        Text(
                          '${userData?.nickName ?? "User empty"} Store',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(Icons.store),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.info,
                          color: Colors.black87,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
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
                                      borderRadius: BorderRadius.circular(24),
                                      child: userData?.profileImagePath != null
                                          ? CachedNetworkImage(
                                              width: double.infinity,
                                              height: double.infinity,
                                              imageUrl:
                                                  'https://${userData!.profileImagePath!}',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.lightGreen,
                                                  strokeWidth: 2,
                                                ),
                                              ),
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
                                              color: AppColors.black,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildStatItem('4.5', 'Rating'),
                                    const SizedBox(width: 32),
                                    _buildStatItem('24.6k', 'Followers'),
                                    const SizedBox(width: 32),
                                    _buildStatItem('62', 'Following'),
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
                                userData?.nickName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                width: 2,
                                height: 16,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                userData?.role ?? 'User Type',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              'A full-service creative studio, specializing in character design',
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
                                  size: 26,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.camera,
                                  size: 26,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.play_circle,
                                  size: 26,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
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
                                  Icons.reviews_outlined,
                                  size: 26,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
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
                                  size: 26,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '13',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
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
                    _buildEmptyTab(
                      icon: CupertinoIcons.video_camera,
                      text: "Empty List",
                    ),
                    _buildEmptyTab(
                      icon: CupertinoIcons.video_camera,
                      text: "Empty List",
                    ),
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
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
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
            AppColors.primaryLight,
            AppColors.black,
            onTap: () {
              // Handle create action
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
                        ? AppColors.black.withOpacity(0.7)
                        : AppColors.transparent),
                borderRadius: index != 0
                    ? BorderRadius.circular(24)
                    : BorderRadius.circular(20)),
            color: AppColors.containerColor,
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
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: index != 0 ? 4 : 7),
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
    );
  }

  Widget _buildProductFilters() {
    return SliverToBoxAdapter(
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 0, left: 0, top: 4),
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
      padding: const EdgeInsets.only(right: 4),
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w700,
              fontSize: 12),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedProductFilter = value;
          });
        },
        backgroundColor: AppColors.containerColor.withOpacity(0.75),
        selectedColor: AppColors.containerColor.withOpacity(0.75),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
              ),
            ),
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
                child: Text("Retry"),
              ),
            ),
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

        return SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 16), // Added padding
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.publications.length) {
                  if (state.isLoading) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return null;
                }

                final publication = state.publications[index];
                return HorizontalProfileProductCard(
                  product: publication,
                );
              },
              childCount: state.publications.length + (state.isLoading ? 1 : 0),
            ),
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
