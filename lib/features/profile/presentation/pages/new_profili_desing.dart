// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';
import 'package:list_in/features/profile/presentation/pages/favorites_screen.dart';
import 'package:list_in/features/profile/presentation/pages/my_publications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    userData.email.toString(),
                                    style: TextStyle(
                                      color: AppColors.darkGray,
                                      fontSize: 17,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1, // Limit to 2 lines
                                    softWrap: true,
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
                                    //
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
                                      child: Text(
                                        AppLocalizations.of(context)!.following,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                      child: Text(
                                        AppLocalizations.of(context)!.followers,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                IconButton(
                                  icon: Icon(CupertinoIcons.share),
                                  onPressed: () => shareUserProfile(
                                    context,
                                    UserProfileEntity(
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
                                      country: userData.country?.valueRu,
                                      state: userData.state?.valueRu,
                                      county: userData.county?.valueRu,
                                    ),
                                  ),
                                  tooltip: "Share Profile",
                                ),
                                //  SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    _navigateToEdit(
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
                                    );
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
                            const SizedBox(width: 8),
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
                          message =
                              "💡 Hello! I have a cool idea for the app: ";
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
        );
      },
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
                context.go(Routes.login);
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

  Widget _buildStatCard(
      String value, String label, Color bgColor, Color textColor) {
    return SmoothClipRRect(
      side: BorderSide(width: 1, color: AppColors.containerColor),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
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

// Updated iOS-style SharePermissionSheet widget
class SharePermissionSheet extends StatefulWidget {
  final UserProfileEntity profile;

  const SharePermissionSheet({super.key, required this.profile});

  @override
  _SharePermissionSheetState createState() => _SharePermissionSheetState();
}

class _SharePermissionSheetState extends State<SharePermissionSheet> {
  bool shareLocation = true;
  bool sharePhone = true;
  bool shareImage = true;

  // Define green color theme
  final Color primaryGreen = AppColors.darkBackground;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        )),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.share_profile,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: AppColors.containerColor),
          SizedBox(height: 4),
          _buildIOSStyleListTile(
            icon: CupertinoIcons.location,
            title: AppLocalizations.of(context)!.share_location,
            value: shareLocation,
            onChanged: (value) => setState(() => shareLocation = value),
          ),
          _buildDivider(),
          _buildIOSStyleListTile(
            icon: CupertinoIcons.phone,
            title: AppLocalizations.of(context)!.share_phone_number,
            value: sharePhone,
            onChanged: (value) => setState(() => sharePhone = value),
          ),
          if (widget.profile.profileImagePath != null &&
              widget.profile.profileImagePath!.isNotEmpty) ...[
            _buildDivider(),
            _buildIOSStyleListTile(
              icon: CupertinoIcons.photo,
              title: AppLocalizations.of(context)!.share_profile_image,
              value: shareImage,
              onChanged: (value) => setState(() => shareImage = value),
            ),
          ],
          _buildDivider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIOSStyleButton(
                  label: localizations.cancel,
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 16),
                _buildIOSStyleButton(
                  label: AppLocalizations.of(context)!.share,
                  onPressed: () => Navigator.pop(context, {
                    'location': shareLocation,
                    'phone': sharePhone,
                    'image': shareImage,
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildIOSStyleListTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryGreen,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryGreen,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 64,
      endIndent: 16,
      color: AppColors.containerColor,
    );
  }

  Widget _buildIOSStyleButton({
    required String label,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: ShapeDecoration(
              color: isOutlined ? Colors.transparent : primaryGreen,
              shape: SmoothRectangleBorder(
                  smoothness: 0.8,
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color:
                          isOutlined ? primaryGreen : AppColors.transparent))),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOutlined ? primaryGreen : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
