// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/di/di_managment.dart';
import 'package:list_in/core/language/screen/language_picker_screen.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/theme/widgets/toggle_button.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/details/presentation/widgets/full_screen_map.dart';
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
import 'package:list_in/features/profile/presentation/widgets/sliver_app_bar.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:list_in/global/likeds/liked_publications_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
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
  final ImagePicker _picker = ImagePicker();
  String selectedProductFilter = 'active';
  bool _isUploadingImage = false;

  void _navigateToEdit(UserProfileEntity userData) {
    context.pushNamed(
      RoutesByName.profileEdit,
      extra: userData,
    );
  }

  // Image selection and update methods
  Future<void> _pickAndUpdateImage(UserProfileEntity userData) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _isUploadingImage = true;
        });

        // Update profile with image
        final updatedProfile = UserProfileEntity(
          nickName: userData.nickName,
          phoneNumber: userData.phoneNumber,
          biography: userData.biography,
          isBusinessAccount: userData.isBusinessAccount,
          isGrantedForPreciseLocation: userData.isGrantedForPreciseLocation,
          fromTime: userData.fromTime,
          toTime: userData.toTime,
          longitude: userData.longitude,
          latitude: userData.latitude,
          county: userData.county,
          state: userData.state,
          country: userData.country,
          locationName: userData.locationName,
        );

        context.read<UserProfileBloc>().add(
              UpdateUserProfileWithImage(
                profile: updatedProfile,
                imageFile: image,
              ),
            );
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  // Method to delete profile image
  void _deleteProfileImage(UserProfileEntity userData) {
    setState(() {
      _isUploadingImage = true;
    });

    final updatedProfile = UserProfileEntity(
      nickName: userData.nickName,
      phoneNumber: userData.phoneNumber,
      biography: userData.biography,
      isBusinessAccount: userData.isBusinessAccount,
      isGrantedForPreciseLocation: userData.isGrantedForPreciseLocation,
      fromTime: userData.fromTime,
      toTime: userData.toTime,
      longitude: userData.longitude,
      latitude: userData.latitude,
      county: userData.county,
      state: userData.state,
      country: userData.country,
      locationName: userData.locationName,
      profileImagePath: '',
    );

    context.read<UserProfileBloc>().add(
          UpdateUserProfileWithImage(profile: updatedProfile),
        );
  }

  // Show enhanced Instagram-style image viewer
  void _showProfileImageViewer(UserProfileEntity userData) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        // Get the screen size for better proportions
        final screenSize = MediaQuery.of(context).size;
        final imageSize = screenSize.width * 0.85; // 85% of screen width

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full screen blurred background with status bar included
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile image - larger size
                      Hero(
                        tag: 'profileImage${userData.nickName}',
                        child: Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: SmoothClipRRect(
                            side: BorderSide(
                              width: 3,
                              color: AppColors.white,
                            ),
                            borderRadius: BorderRadius.circular(imageSize / 2),
                            child: userData.profileImagePath != null &&
                                    userData.profileImagePath!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'https://${userData.profileImagePath}',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.black26,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.black26,
                                      child: Image.asset(
                                        AppImages.appLogo,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.black26,
                                    child: Image.asset(
                                      AppImages.appLogo,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Action buttons with enhanced appearance
                      SmoothClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          color: Colors.black.withOpacity(0.4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: Icons.edit,
                                label:
                                    AppLocalizations.of(context)!.edit_profile,
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickAndUpdateImage(userData);
                                },
                              ),

                              // Only show delete button if there's an image
                              if (userData.profileImagePath != null &&
                                  userData.profileImagePath!.isNotEmpty) ...[
                                Container(
                                  height: 30,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  color: Colors.white38,
                                ),
                                _buildActionButton(
                                  icon: Icons.delete,
                                  label: AppLocalizations.of(context)!.delete,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteProfileImage(userData);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Close button with improved positioning and shadow
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 32,
                child: InkWell(
                  child: const Icon(
                    Icons.close_rounded,
                    size: 32,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper method for consistent action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 22,
        shadows: const [
          Shadow(color: Colors.black54, blurRadius: 3),
        ],
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 3),
          ],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
          setState(() {
            _isUploadingImage = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        } else if (state.status == UserProfileStatus.success &&
            _isUploadingImage) {
          setState(() {
            _isUploadingImage = false;
          });
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

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.profile,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              ThemeToggle(),
              const SizedBox(width: 12),
            ],
          ),
          body: RefreshIndicator(
            color: Colors.blue,
            backgroundColor: Theme.of(context).cardColor,
            elevation: 1,
            strokeWidth: 3,
            displacement: 40,
            edgeOffset: 10,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () {
              context.read<UserProfileBloc>().add(GetUserData());
              context.read<UserPublicationsBloc>().add(FetchUserPublications());
              context
                  .read<LikedPublicationsBloc>()
                  .add(FetchLikedPublications());
              return Future<
                  void>.value(); // This is the correct way to return a completed Future
            },
            child: NestedScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 24,
                        top: 12,
                        bottom: 12,
                      ),
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
                                    GestureDetector(
                                      onTap: () => _showProfileImageViewer(
                                        UserProfileEntity(
                                          isBusinessAccount: userData.role !=
                                              "INDIVIDUAL_SELLER",
                                          locationName: userData.locationName,
                                          longitude: userData.longitude,
                                          latitude: userData.latitude,
                                          fromTime: userData.fromTime,
                                          toTime: userData.toTime,
                                          isGrantedForPreciseLocation: userData
                                              .isGrantedForPreciseLocation,
                                          nickName: userData.nickName,
                                          phoneNumber: userData.phoneNumber,
                                          profileImagePath:
                                              userData.profileImagePath,
                                          country: userData.country?.valueRu,
                                          state: userData.state?.valueRu,
                                          county: userData.county?.valueRu,
                                        ),
                                      ),
                                      child: SmoothClipRRect(
                                        smoothness: 0.8,
                                        side: BorderSide(
                                          width: 2,
                                          color: Theme.of(context).cardColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: _isUploadingImage
                                            ? Container(
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withOpacity(0.2),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              )
                                            : (userData.profileImagePath !=
                                                        null &&
                                                    userData.profileImagePath!
                                                        .isNotEmpty
                                                ? CachedNetworkImage(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    imageUrl:
                                                        'https://${userData.profileImagePath}',
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      AppImages.appLogo,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.appLogo,
                                                    fit: BoxFit.cover,
                                                  )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Transform.translate(
                                        offset: Offset(0, 0),
                                        child: SmoothClipRRect(
                                          side: BorderSide(
                                            width: 1,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: InkWell(
                                            onTap: _isUploadingImage
                                                ? null // Disable when uploading
                                                : () => _pickAndUpdateImage(
                                                      UserProfileEntity(
                                                        isBusinessAccount: userData
                                                                .role !=
                                                            "INDIVIDUAL_SELLER",
                                                        locationName: userData
                                                            .locationName,
                                                        longitude:
                                                            userData.longitude,
                                                        latitude:
                                                            userData.latitude,
                                                        fromTime:
                                                            userData.fromTime,
                                                        toTime: userData.toTime,
                                                        isGrantedForPreciseLocation:
                                                            userData
                                                                .isGrantedForPreciseLocation,
                                                        nickName:
                                                            userData.nickName,
                                                        phoneNumber: userData
                                                            .phoneNumber,
                                                        profileImagePath: userData
                                                            .profileImagePath,
                                                        country: userData
                                                            .country?.valueRu,
                                                        state: userData
                                                            .state?.valueRu,
                                                        county: userData
                                                            .county?.valueRu,
                                                      ),
                                                    ),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: Center(
                                                child: _isUploadingImage
                                                    ? SizedBox(
                                                        width: 10,
                                                        height: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                      )
                                                    : Icon(
                                                        size: 16,
                                                        Icons.edit,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
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
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildStatItem(
                                      userData.rating.toString() == "null"
                                          ? '0'
                                          : userData.rating.toInt().toString(),
                                      AppLocalizations.of(context)!.rating,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.push(
                                          Routes.socialConnections,
                                          extra: {
                                            'userId': userData.id,
                                            'username': userData.nickName,
                                            'initialTab': 'followers',
                                          },
                                        );
                                      },
                                      child: _buildStatItem(
                                        userData.followers.toString(),
                                        AppLocalizations.of(context)!.followers,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.push(
                                          Routes.socialConnections,
                                          extra: {
                                            'userId': userData.id,
                                            'username': userData.nickName,
                                            'initialTab': 'followings',
                                          },
                                        );
                                      },
                                      child: _buildStatItem(
                                        userData.following.toString(),
                                        AppLocalizations.of(context)!.following,
                                      ),
                                    ),
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
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
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
                    delegate: SliverTabBarDelegate(
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
                                    fontFamily: Constants.Arial,
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
                                  AppLocalizations.of(context)!.favorites,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: Constants.Arial,
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
                                  AppLocalizations.of(context)!.account,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: Constants.Arial,
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
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.secondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
            AppLocalizations.of(context)!.share_profile,
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
            AppLocalizations.of(context)!.edit_profile,
            Theme.of(context).cardColor,
            AppColors.black,
            onTap: () {
              _navigateToEdit(
                UserProfileEntity(
                  isBusinessAccount: user?.role != "INDIVIDUAL_SELLER",
                  locationName: user?.locationName,
                  longitude: user?.longitude,
                  latitude: user?.latitude,
                  fromTime: user?.fromTime,
                  toTime: user?.toTime,
                  isGrantedForPreciseLocation:
                      user?.isGrantedForPreciseLocation,
                  nickName: user?.nickName,
                  phoneNumber: user?.phoneNumber,
                  profileImagePath: user?.profileImagePath,
                  country: userData.country?.valueRu,
                  state: userData.state?.valueRu,
                  county: userData.county?.valueRu,
                ),
              );
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
        shadowColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        shape: SmoothRectangleBorder(
            side: BorderSide(
              width: index == 0 ? 1 : 0,
              color: index == 0
                  ? Theme.of(context).cardColor
                  : AppColors.transparent,
            ),
            borderRadius: index != 0
                ? BorderRadius.circular(20)
                : BorderRadius.circular(20)),
        color: index == 0
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).colorScheme.secondary,
        child: Container(
          margin: EdgeInsets.zero,
          // width: 120,
          height: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: index == 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).scaffoldBackgroundColor,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: index == 0
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).scaffoldBackgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $selectedProductFilter products',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }

        // Content state with grid
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
              childAspectRatio: 0.7,
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
              childAspectRatio: 0.75,
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
                        fontWeight: FontWeight.w600,
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
