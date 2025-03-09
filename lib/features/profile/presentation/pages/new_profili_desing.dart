// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/language/screen/language_picker_screen.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';
import 'package:list_in/features/profile/presentation/pages/favorites_screen.dart';
import 'package:list_in/features/profile/presentation/pages/my_publications.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({super.key});

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(GetUserData());
  }

  void _navigateToEdit(UserProfileEntity userData) {
    context.pushNamed(
      RoutesByName.profileEdit,
      extra: userData,
    );
  }

  Future<bool> _onWillPop() async {
    context.go(Routes.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ??
                    AppLocalizations.of(context)!.unknown_error)),
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
          return Scaffold(
              body: Center(
                  child: Text(AppLocalizations.of(context)!.no_user_data)));
        }
        if (state.userData == null) {}
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _onWillPop();
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.profile,
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.moon,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                    2), // White border thickness
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      height: double.infinity,
                                      imageUrl:
                                          'https://${userData.profileImagePath}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Progress(),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(AppImages.appLogo),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userData.nickName}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userData.biography ??
                                      AppLocalizations.of(context)!
                                          .no_biography,
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // space children apart
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // center them vertically
                          children: [
                            // Left side or main content
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.follow,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      userData.following.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.followers,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      userData.followers.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Right side icons
                            Row(
                              children: [
                                Icon(CupertinoIcons.share),
                                SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    _navigateToEdit(UserProfileEntity(
                                      isBusinessAccount:
                                          userData.role != "INDIVIDUAL_SELLER",
                                      locationName: userData.locationName,
                                      longitude: userData.longitude,
                                      latitude: userData.latitude,
                                      fromTime: userData.fromTime,
                                      toTime: userData.toTime,
                                      isGrantedForPreciseLocation:
                                          userData.isGrantedForPreciseLocation,
                                      nickName: userData.nickName,
                                      phoneNumber: userData.phoneNumber,
                                      profileImagePath:
                                          userData.profileImagePath,
                                    ));
                                  },
                                  icon: Icon(Icons.edit_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UserPublicationsScreen(),
                                    ),
                                  );
                                },
                                child: _buildStatCard(
                                  AppLocalizations.of(context)!.posts,
                                  '⟶',
                                  Colors.white,
                                  Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildStatCard(
                                AppLocalizations.of(context)!.reviews,
                                '⟶',
                                Colors.white,
                                Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FavoritesScreen(),
                                    ),
                                  );
                                },
                                child: _buildStatCard(
                                  AppLocalizations.of(context)!.favorites,
                                  '⟶',
                                  Colors.white,
                                  Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
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
                    () {},
                  ),
                  _buildMenuItem(
                    AppLocalizations.of(context)!.support,
                    AppIcons.supportIc,
                    () {},
                  ),

                  _buildMenuItem(
                    AppLocalizations.of(context)!.logout,
                    AppIcons.logoutIc,
                    () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String value, String label, Color bgColor, Color textColor) {
    return SmoothClipRRect(
      side: BorderSide(width: 1, color: AppColors.containerColor),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 25,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                  color: Colors.black,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.black),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: Divider(
                height: 0.5,
                color: AppColors.containerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
