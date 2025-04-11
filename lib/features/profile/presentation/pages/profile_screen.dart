// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/di/di_managment.dart';
import 'package:list_in/core/language/screen/language_picker_screen.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
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
import 'package:list_in/features/profile/presentation/pages/new_profili_desing.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:list_in/global/likeds/liked_publications_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
        } //
        if (state.userData == null) {}

        return SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: NestedScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    snap: false,
                    toolbarHeight: 56,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    scrolledUnderElevation: 0,
                    title: Row(
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
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
                                width: 82,
                                height: 82,
                                child: Stack(
                                  children: [
                                    SmoothClipRRect(
                                      smoothness: 0.8,
                                      side: BorderSide(
                                        width: 2,
                                        color: AppColors.containerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
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
                                        offset: Offset(0, 0),
                                        child: SmoothClipRRect(
                                          side: BorderSide(
                                            width: 1,
                                            color: AppColors.containerColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: InkWell(
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              color: AppColors.white,
                                              child: Center(
                                                child: Icon(
                                                  size: 16,
                                                  Icons.edit,
                                                  color: AppColors.black,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildStatItem(
                                    userData.rating.toString() == "null"
                                        ? '0'
                                        : userData.rating.toInt().toString(),
                                    'Rating',
                                  ),
                                  const SizedBox(width: 32),
                                  _buildStatItem(userData.followers.toString(),
                                      'Followers'),
                                  const SizedBox(width: 32),
                                  _buildStatItem(userData.following.toString(),
                                      'Following'),
                                ],
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
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              userData.biography ??
                                  AppLocalizations.of(context)!.no_biography,
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
                    child: Row(
                      children: [
                        _buildContactActions(
                          userData,
                          state,
                        ),
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
                                  size: 22,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.heart_circle,
                                  size: 22,
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
                          Tab(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.person,
                                  size: 22,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Account',
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
                        indicator: const BoxDecoration(
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
                padding: const EdgeInsets.only(top: 8, right: 8, left: 4),
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
                    ),
                    _buildAccountTab(
                      state: state,
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
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildContactActions(UserDataEntity? user, UserProfileState state) {
    final userData = state.userData!;
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 8,
        bottom: 20,
        top: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionItem(
            1,
            Icons.share,
            'Share profile',
            AppColors.white,
            AppColors.black,
            onTap: () => shareUserProfile(
              context,
              UserProfileEntity(
                isBusinessAccount: userData.role != "INDIVIDUAL_SELLER",
                locationName: userData.locationName,
                longitude: userData.longitude,
                latitude: userData.latitude,
                fromTime: userData.fromTime,
                toTime: userData.toTime,
                isGrantedForPreciseLocation:
                    userData.isGrantedForPreciseLocation,
                nickName: userData.nickName,
                phoneNumber: userData.phoneNumber,
                profileImagePath: userData.profileImagePath,
                country: userData.country?.valueRu,
                state: userData.state?.valueRu,
                county: userData.county?.valueRu,
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          _buildActionItem(
            0,
            Icons.edit,
            'Edit profile',
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
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.white.withOpacity(0.5),
        shape: SmoothRectangleBorder(
            side: BorderSide(
              width: index == 0 ? 1 : 0,
              color:
                  index == 0 ? AppColors.containerColor : AppColors.transparent,
            ),
            borderRadius: index != 0
                ? BorderRadius.circular(20)
                : BorderRadius.circular(20)),
        color: index == 0 ? AppColors.white : AppColors.black,
        child: Container(
          margin: EdgeInsets.zero,
          width: 120,
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: index == 0 ? AppColors.black : AppColors.white,
                size: 18,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: index == 0 ? AppColors.black : AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
              childAspectRatio: 0.65,
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

  Widget _buildAccountTab({
    required UserProfileState state,
  }) {
    final userData = state.userData!;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              children: [
                // balance, language, suppport,  logout,
                _buildMenuItem(
                  userData.locationName ??
                      AppLocalizations.of(context)!.not_selected,
                  AppIcons.homeLocationIc,
                  () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => FullScreenMap(
                          latitude: userData.latitude!,
                          longitude: userData.longitude!,
                          locationName: userData.locationName ??
                              AppLocalizations.of(context)!.no_location,
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  AppLocalizations.of(context)!.language,
                  AppIcons.languageIc,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LanguageSelectionScreen()),
                    );
                  },
                ),

                _buildMenuItem(
                  AppLocalizations.of(context)!.help_idea,
                  AppIcons.ideaIc,
                  () {
                    final String languageCode =
                        Localizations.localeOf(context).languageCode;
                    String message;

                    switch (languageCode) {
                      case 'uz':
                        message =
                            "💡 Salom! Men ilova uchun ajoyib g'oyaga ega man: ";
                        break;
                      case 'en':
                        message = "💡 Hello! I have a cool idea for the app: ";
                        break;
                      case 'ru':
                      default:
                        message =
                            "💡 Привет! У меня есть отличная идея для приложения: ";
                        break;
                    }

                    _openTelegram(context, message);
                  },
                ),

                _buildMenuItem(
                  AppLocalizations.of(context)!.support,
                  AppIcons.supportIc,
                  () {
                    final String languageCode =
                        Localizations.localeOf(context).languageCode;
                    String message;

                    switch (languageCode) {
                      case 'uz':
                        message =
                            "🆘 Yordam kerak! Men ilovada quyidagi muammoga duch kelmoqdaman: ";
                        break;
                      case 'en':
                        message =
                            "🆘 Help needed! I'm experiencing the following issue with the app: ";
                        break;
                      case 'ru':
                      default:
                        message =
                            "🆘 Нужна помощь! У меня возникла следующая проблема с приложением: ";
                        break;
                    }

                    _openTelegram(context, message);
                  },
                ),

                _buildMenuItem(
                  AppLocalizations.of(context)!.logout,
                  AppIcons.logoutIc,
                  () => _handleLogout(context),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, String image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 18,
            ),
            Row(
              children: [
                Image.asset(
                  image,
                  width: 20,
                  height: 20,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: Divider(
                height: 0.5,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> shareUserProfile(
      BuildContext context, UserProfileEntity profile) async {
    final String appName = "ListIn";

    // Show permission dialog
    final permissionResult = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SharePermissionSheet(profile: profile);
      },
    );

    // If user canceled, return
    if (permissionResult == null) return;

    final bool shareLocation = permissionResult['location'] ?? false;
    final bool sharePhone = permissionResult['phone'] ?? false;
    final bool shareImage = permissionResult['image'] ?? false;

    // Create base message with appropriate localization and enhanced stickers
    String message = _getLocalizedGreeting(context, appName, profile.nickName);

    // Add business information if applicable
    if (profile.isBusinessAccount == true) {
      message += _getLocalizedBusinessInfo(context, profile.nickName!);
    }

    // Add location if permitted
    if (shareLocation &&
        profile.locationName != null &&
        profile.locationName!.isNotEmpty) {
      message += _getLocalizedLocation(context, profile.locationName!);
    }

    // Add phone if permitted
    if (sharePhone &&
        profile.phoneNumber != null &&
        profile.phoneNumber!.isNotEmpty) {
      message += _getLocalizedPhone(context, profile.phoneNumber!);
    }

    // Add image URL if permitted
    if (shareImage &&
        profile.profileImagePath != null &&
        profile.profileImagePath!.isNotEmpty) {
      // Ensure the URL starts with 'https://'
      String imageUrl = profile.profileImagePath!;
      if (!imageUrl.startsWith('http')) {
        imageUrl = 'https://$imageUrl';
      }
      message += _getLocalizedProfileImage(context, imageUrl);
    }

    // Add app description and download link with enhanced stickers
    message += _getLocalizedAppPromo(context, appName);

    // App download links with attention-grabbing stickers
    final String appLink = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=com.listIn.marketplace&pcampaignid=web_share"
        : "https://apps.apple.com/app/listin-marketplace/id123456789";

    message += "\n\n⬇️ $appLink ⬇️";

    // Final call-to-action with stickers
    message += "\n\n" + _getLocalizedCallToAction(context);

    // Text-only sharing
    await Share.share(
      message,
      subject: "✨ Join me on $appName! ✨",
    );
  }

// Helper method to get localized greeting with enhanced stickers
  String _getLocalizedGreeting(
      BuildContext context, String appName, String? nickName) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "👋 Salom! 🌟 Men $appName ilovasida $nickName sifatida ro'yxatdan o'tdim. 🎉\n\n";
      case 'en':
        return "👋 Hello there! 🌟 I joined $appName as $nickName. 🎉\n\n";
      case 'ru':
      default:
        return "👋 Привет! 🌟 Я присоединился к $appName как $nickName. 🎉\n\n";
    }
  }

// Helper method to get localized business info with stickers
  String _getLocalizedBusinessInfo(BuildContext context, String nickName) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "🏢 Biznesim: $nickName\n";
      case 'en':
        return "🏢 My business: $nickName\n";
      case 'ru':
      default:
        return "🏢 Мой бизнес: $nickName\n";
    }
  }

// Helper method to get localized location with stickers
  String _getLocalizedLocation(BuildContext context, String location) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "📍 Manzil: $location\n";
      case 'en':
        return "📍 Location: $location\n";
      case 'ru':
      default:
        return "📍 Адрес: $location\n";
    }
  }

// Helper method to get localized phone with stickers
  String _getLocalizedPhone(BuildContext context, String phone) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "📱 Telefon: $phone\n\n";
      case 'en':
        return "📱 Phone: $phone\n\n";
      case 'ru':
      default:
        return "📱 Телефон: $phone\n\n";
    }
  }

// Helper method to get localized profile image with stickers
  String _getLocalizedProfileImage(BuildContext context, String imageUrl) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "🖼️ Profil rasmi: $imageUrl\n";
      case 'en':
        return "🖼️ Profile picture: $imageUrl\n";
      case 'ru':
      default:
        return "🖼️ Фото профиля: $imageUrl\n";
    }
  }

// Helper method to get localized app promo text with stickers
  String _getLocalizedAppPromo(BuildContext context, String appName) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "✨ $appName - eng yangi va qulay bozor ilova! 🛍️\n\n🔥 Tezkor savdo-sotiq! 💯 Qulay interfeysda! 🚀 Eng zo'r takliflar!";
      case 'en':
        return "✨ $appName - the newest and most interactive marketplace! 🛍️\n\n🔥 Fast trading! 💯 User-friendly interface! 🚀 Best deals!";
      case 'ru':
      default:
        return "✨ $appName - самый новый и удобный маркетплейс! 🛍️\n\n🔥 Быстрая торговля! 💯 Удобный интерфейс! 🚀 Лучшие предложения!";
    }
  }

// New helper method for call to action with stickers
  String _getLocalizedCallToAction(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'uz':
        return "🤝 Menga qo'shiling va bizni keng jamiyatimizning bir qismi bo'ling! 🌐\n💰 Eng yaxshi takliflarni toping va sotib oling! 🎁";
      case 'en':
        return "🤝 Join me and be part of our growing community! 🌐\n💰 Find and buy the best deals! 🎁";
      case 'ru':
      default:
        return "🤝 Присоединяйтесь ко мне и станьте частью нашего растущего сообщества! 🌐\n💰 Находите и покупайте лучшие предложения! 🎁";
    }
  }

  void _openTelegram(BuildContext context, String message) {
    final String username = "FlyEnebo";
    final String encodedMessage = Uri.encodeComponent(message);
    final String url = "https://t.me/$username?text=$encodedMessage";

    try {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error based on language
      final String languageCode = Localizations.localeOf(context).languageCode;
      String errorMessage;

      switch (languageCode) {
        case 'uz':
          errorMessage = "Telegram ilovasini ochib bo'lmadi";
          break;
        case 'en':
          errorMessage = "Could not open Telegram";
          break;
        case 'ru':
        default:
          errorMessage = "Не удалось открыть Telegram";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorMessage,
                style: TextStyle(fontFamily: Constants.Arial))),
      );
    }
  }

  void _handleLogout(BuildContext context) {
    // Show iOS-style action sheet menu
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(fontFamily: Constants.Arial),
          ),
          message: Text(
            AppLocalizations.of(context)!.logout_confirmation,
            style: TextStyle(fontFamily: Constants.Arial),
          ),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                // Clear all cached data
                final authLocalDataSource = sl<AuthLocalDataSource>();
                await authLocalDataSource.clearAuthToken();
                await authLocalDataSource.deleteRetrivedEmail();
                await authLocalDataSource.cacheUserId(null);
                await authLocalDataSource.cacheProfileImagePath(null);

                // Close action sheet
                Navigator.of(context).pop();

                // Navigate to login page
                context.go(Routes.welcome);
              },
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: TextStyle(
                  fontFamily: Constants.Arial,
                  fontSize: 18,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                fontFamily: Constants.Arial,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
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
          Expanded(
            child: TabBar(
              padding: EdgeInsets.zero,
              controller: tabBar.controller,
              tabs: tabBar.tabs,
              indicatorColor: AppColors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.grey,
              labelPadding: const EdgeInsets.symmetric(vertical: 0),
              dividerColor: Colors.transparent,
              overlayColor:
                  MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 0),
            child: Container(
              height: 1, // Height of the bottom grey line
              color:
                  Colors.grey.withOpacity(0.1), // Light grey color for the line
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
