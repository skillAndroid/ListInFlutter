// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_profile_entity.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_bloc.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_event.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_state.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreProfilePage extends StatefulWidget {
  final String userId;
  const StoreProfilePage({
    super.key,
    required this.userId,
  });
//sa
  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  bool _isImagePopupVisible =
      false; // State variable to control popup visibility
  void _toggleImagePopup() {
    setState(() {
      _isImagePopupVisible = !_isImagePopupVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<AnotherUserProfileBloc>().add(ClearUserData());

    context
        .read<AnotherUserProfileBloc>()
        .add(GetAnotherUserData(widget.userId));
    context.read<AnotherUserProfileBloc>().add(
          FetchPublications(
            userId: widget.userId,
            isInitialFetch: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isImagePopupVisible) {
          setState(() {
            _isImagePopupVisible = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: BlocConsumer<AnotherUserProfileBloc, AnotherUserProfileState>(
        listener: (context, state) {
          if (state.status == AnotherUserProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ??
                      AppLocalizations.of(context)!.an_error_occurred)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AnotherUserProfileStatus.loading &&
              state.profile == null) {
            return const Scaffold(body: Progress());
          }

          final userData = state.profile;

          if (userData == null) {
            return Scaffold(
                body: Center(
                    child: Text(AppLocalizations.of(context)!.no_user_data)));
          }
          return DefaultTabController(
            length: 4, // Number of tabs
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: AppColors.white,
                  appBar: AppBar(
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: AppColors.white,
                    actions: [
                      IconButton(
                        icon: Icon(CupertinoIcons.phone, color: Colors.black),
                        onPressed: () {
                          _makeCall(context, "${userData.phoneNumber}");
                        },
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.bubble_left,
                            color: Colors.black),
                        onPressed: () {
                          final String phoneNumber =
                              userData.phoneNumber.toString();
                          _openTelegram(context, phoneNumber);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                    title: Text(
                      AppLocalizations.of(context)!.store,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: 220,
                            collapsedHeight: 84,
                            floating: false,
                            pinned: true,
                            surfaceTintColor: AppColors.white,
                            shadowColor: AppColors.transparent,
                            backgroundColor: AppColors.containerColor2,
                            automaticallyImplyLeading: false,
                            flexibleSpace: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                // Get the top scroll position
                                final double expandRatio =
                                    (constraints.maxHeight - kToolbarHeight) /
                                        (220 - kToolbarHeight);
                                final double parallaxOffset =
                                    (1.0 - expandRatio.clamp(0.0, 1.0)) * 80;

                                // Calculate opacity for the fixed animated container
                                // Show when collapsed to 50% (expandRatio ≈ 0.5), hide when expanded to 55% (expandRatio ≈ 0.55)
                                final double containerOpacity = expandRatio <=
                                        0.5
                                    ? 1.0
                                    : expandRatio >= 0.55
                                        ? 0.0
                                        : (0.55 - expandRatio) *
                                            20; // Smooth transition in the 0.5-0.55 range

                                final double titleOpacity = expandRatio > 0.7
                                    ? 0.0
                                    : ((0.7 - expandRatio) * (10 / 3))
                                        .clamp(0.0, 1.0);

                                return Stack(
                                  children: [
                                    FlexibleSpaceBar(
                                      background: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Banner with parallax effect
                                          Positioned(
                                            top: -parallaxOffset,
                                            left: 0,
                                            right: 0,
                                            height: 220 - 120,
                                            child: userData.profileImagePath !=
                                                    null
                                                ? CachedNetworkImage(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    imageUrl:
                                                        'https://${userData.profileImagePath!}',
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Colors.lightGreen,
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
                                                  ),
                                          ),

                                          // Top white container with opacity animation
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            height:
                                                60, // Height for top container
                                            child: AnimatedOpacity(
                                              opacity:
                                                  titleOpacity, // Using same opacity logic as title
                                              duration:
                                                  Duration(milliseconds: 150),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      AppColors.containerColor2,
                                                      AppColors.containerColor2
                                                          .withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Gradient overlay
                                          AnimatedOpacity(
                                            opacity: (1.0 -
                                                    expandRatio.clamp(
                                                        0.0, 1.0)) *
                                                0.5,
                                            duration:
                                                Duration(milliseconds: 150),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black
                                                        .withOpacity(0.3),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Profile section with parallax effect
                                          Positioned(
                                            bottom: 0 + (parallaxOffset * 0.5),
                                            left: 0,
                                            right: 0,
                                            height: 130,
                                            child: Container(
                                              color: AppColors.containerColor2,
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16,
                                                top: 16,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Profile Image with parallax
                                                  // Profile Image with parallax
                                                  GestureDetector(
                                                    onTap:
                                                        _toggleImagePopup, // Handle tap on profile image
                                                    child: Transform.translate(
                                                      offset: Offset(
                                                          0,
                                                          -parallaxOffset *
                                                              0.3),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: SizedBox(
                                                          width: 88,
                                                          height: 88,
                                                          child: userData
                                                                      .profileImagePath !=
                                                                  null
                                                              ? CachedNetworkImage(
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  imageUrl:
                                                                      'https://${userData.profileImagePath!}',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .lightGreen,
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image.asset(
                                                                          AppImages
                                                                              .appLogo),
                                                                )
                                                              : Image.asset(
                                                                  AppImages
                                                                      .appLogo),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: 16),
                                                  // Store Info with parallax
                                                  BlocBuilder<GlobalBloc,
                                                      GlobalState>(
                                                    builder: (context, state) {
                                                      final followersCount =
                                                          state
                                                              .getFollowersCount(
                                                                  userData.id ??
                                                                      '');
                                                      final followingCount =
                                                          state
                                                              .getFollowingCount(
                                                                  userData.id ??
                                                                      '');
                                                      return Expanded(
                                                        child:
                                                            Transform.translate(
                                                          offset: Offset(
                                                              0,
                                                              -parallaxOffset *
                                                                  0.2), // Text moves up slightly
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                userData.nickName ??
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .no_user_name,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 21,
                                                                  height: 1.3,
                                                                  fontFamily:
                                                                      Constants
                                                                          .Arial,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          '$followersCount ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            Constants.Arial,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .followers,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            Constants.Arial,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          '${userData.rating}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            Constants.Arial,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          ' ${AppLocalizations.of(context)!.rating} (0 ${AppLocalizations.of(context)!.reviews})',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            Constants.Arial,
                                                                        fontSize:
                                                                            12,
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
                                                  ),
                                                  // Follow Button - replacing the favorite button
                                                  BlocBuilder<GlobalBloc,
                                                      GlobalState>(
                                                    builder: (context, state) {
                                                      final isFollowed =
                                                          state.isUserFollowed(
                                                              widget.userId);
                                                      final followStatus =
                                                          state.getFollowStatus(
                                                              widget.userId);
                                                      final isLoading =
                                                          followStatus ==
                                                              FollowStatus
                                                                  .inProgress;
                                                      return Transform
                                                          .translate(
                                                        offset: Offset(
                                                            0,
                                                            -parallaxOffset *
                                                                0.3),
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 8),
                                                          height: 36,
                                                          child: ElevatedButton(
                                                            onPressed: isLoading
                                                                ? null
                                                                : () {
                                                                    context
                                                                        .read<
                                                                            GlobalBloc>()
                                                                        .add(
                                                                          UpdateFollowStatusEvent(
                                                                            userId:
                                                                                widget.userId,
                                                                            isFollowed:
                                                                                isFollowed,
                                                                            context:
                                                                                context,
                                                                          ),
                                                                        );
                                                                  },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  CupertinoColors
                                                                      .white,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              elevation: 0,
                                                              shape:
                                                                  SmoothRectangleBorder(
                                                                side: BorderSide(
                                                                    width: 1,
                                                                    color: AppColors
                                                                        .black),
                                                                borderRadius:
                                                                    SmoothBorderRadius(
                                                                  cornerRadius:
                                                                      18,
                                                                  cornerSmoothing:
                                                                      0.7,
                                                                ),
                                                              ),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 16,
                                                              ),
                                                            ),
                                                            child: isLoading
                                                                ? const Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(8),
                                                                    child:
                                                                        SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          Colors
                                                                              .black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        isFollowed
                                                                            ? Icons.remove
                                                                            : Icons.add,
                                                                        size:
                                                                            16,
                                                                        color: AppColors
                                                                            .black,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        isFollowed
                                                                            ? AppLocalizations.of(context)!.unfollow
                                                                            : AppLocalizations.of(context)!.follow,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              Constants.Arial,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              AppColors.black,
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      collapseMode: CollapseMode.parallax,
                                      centerTitle: false,
                                    ),

                                    // FIXED container on top that's only affected by visibility animation
                                    // This container is completely separate from the collapsing content
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 70,
                                      child: AnimatedOpacity(
                                        opacity: containerOpacity,
                                        duration: Duration(
                                            milliseconds:
                                                100), // 100ms animation
                                        child: Container(
                                          color: AppColors.containerColor2,
                                          child: SafeArea(
                                            top: true,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap:
                                                            _toggleImagePopup,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            100,
                                                          ),
                                                          child: SizedBox(
                                                            width: 48,
                                                            height: 48,
                                                            child: userData
                                                                        .profileImagePath !=
                                                                    null
                                                                ? CachedNetworkImage(
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    imageUrl:
                                                                        'https://${userData.profileImagePath!}',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            const Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        color: Colors
                                                                            .lightGreen,
                                                                        strokeWidth:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      AppImages
                                                                          .appLogo,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  )
                                                                : Image.asset(
                                                                    AppImages
                                                                        .appLogo,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            userData.nickName ??
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .user,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      '${userData.rating} ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        Constants
                                                                            .Arial,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${AppLocalizations.of(context)!.rating} (0 ${AppLocalizations.of(context)!.reviews})',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontFamily:
                                                                        Constants
                                                                            .Arial,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  BlocBuilder<GlobalBloc,
                                                      GlobalState>(
                                                    builder: (context, state) {
                                                      final isFollowed =
                                                          state.isUserFollowed(
                                                              widget.userId);
                                                      final followStatus =
                                                          state.getFollowStatus(
                                                              widget.userId);
                                                      final isLoading =
                                                          followStatus ==
                                                              FollowStatus
                                                                  .inProgress;
                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            top: 0),
                                                        height: 36,
                                                        child: ElevatedButton(
                                                          onPressed: isLoading
                                                              ? null
                                                              : () {
                                                                  context
                                                                      .read<
                                                                          GlobalBloc>()
                                                                      .add(
                                                                        UpdateFollowStatusEvent(
                                                                          userId:
                                                                              widget.userId,
                                                                          isFollowed:
                                                                              isFollowed,
                                                                          context:
                                                                              context,
                                                                        ),
                                                                      );
                                                                },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                CupertinoColors
                                                                    .white,
                                                            foregroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                            shape:
                                                                SmoothRectangleBorder(
                                                              side: BorderSide(
                                                                  width: 1,
                                                                  color: AppColors
                                                                      .black),
                                                              borderRadius:
                                                                  SmoothBorderRadius(
                                                                cornerRadius:
                                                                    18,
                                                                cornerSmoothing:
                                                                    0.7,
                                                              ),
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 16,
                                                            ),
                                                          ),
                                                          child: isLoading
                                                              ? const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<
                                                                              Color>(
                                                                        Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      isFollowed
                                                                          ? Icons
                                                                              .remove
                                                                          : Icons
                                                                              .add,
                                                                      size: 16,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      isFollowed
                                                                          ? AppLocalizations.of(context)!
                                                                              .unfollow
                                                                          : AppLocalizations.of(context)!
                                                                              .follow,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            Constants.Arial,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: AppColors
                                                                            .black,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              TabBar(
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.black,
                                indicatorWeight: 0.1,
                                dividerColor: AppColors.transparent,
                                isScrollable: true, // Makes tabs scrollable
                                labelPadding: EdgeInsets.symmetric(
                                    horizontal: 20), // Padding between tabs
                                indicatorSize: TabBarIndicatorSize
                                    .label, // Makes indicator match tab width
                                tabAlignment: TabAlignment
                                    .start, // Aligns tabs to the start (left)
                                labelStyle: const TextStyle(
                                  fontFamily: Constants.Arial,
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontFamily: Constants.Arial,
                                  fontWeight: FontWeight.w500,
                                ),

                                tabs: [
                                  Tab(text: AppLocalizations.of(context)!.shop),
                                  Tab(
                                      text:
                                          AppLocalizations.of(context)!.about),
                                  Tab(
                                      text: AppLocalizations.of(context)!
                                          .reviews_big),
                                ],
                              ),
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      // Tab content that scrolls underneath
                      body: TabBarView(
                        children: [
                          // Use unique PageStorageKey for each tab
                          ShopTabContent(key: PageStorageKey('shop_tab')),
                          AboutTabContent(
                            key: PageStorageKey('about_tab'),
                            user: userData,
                          ),
                          Center(
                              key: PageStorageKey('feedback_tab'),
                              child: Text(AppLocalizations.of(context)!
                                  .no_reviews_yet)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isImagePopupVisible)
                  GestureDetector(
                    onTap: _toggleImagePopup,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ),

                // Centered image popup
                if (_isImagePopupVisible)
                  Center(
                    child: GestureDetector(
                      onTap: _toggleImagePopup, // Close popup on tap
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeInOut,
                        ),
                        child: AnimatedOpacity(
                          opacity: _isImagePopupVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      'https://${userData.profileImagePath}'),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _openTelegram(BuildContext context, String phoneNumber) {
  // Format phone number by removing any non-digit characters
  final String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  // Create simple greeting message based on language
  final String languageCode = Localizations.localeOf(context).languageCode;
  String message;
  switch (languageCode) {
    case 'uz':
      message = "Salom! Qandaysiz?";
      break;
    case 'en':
      message = "Hello! How are you?";
      break;
    case 'ru':
    default:
      message = "Здравствуйте! Как дела?";
      break;
  }

  // Create the Telegram URL with phone number and encoded message
  final String encodedMessage = Uri.encodeComponent(message);
  final String url = "https://t.me/$formattedPhone?text=$encodedMessage";

  try {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    // Handle error based on language
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
        content:
            Text(errorMessage, style: TextStyle(fontFamily: Constants.Arial)),
      ),
    );
  }
}

Future<void> _makeCall(BuildContext context, String phoneNumber) async {
  final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  final String uriString = 'tel:$cleanPhoneNumber';

  try {
    if (await canLaunchUrl(Uri.parse(uriString))) {
      await launchUrl(Uri.parse(uriString));
    } else {
      debugPrint("🤙Cannot launch URL: $uriString");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: Unable to launch call to $cleanPhoneNumber")),
      );
    }
  } catch (e) {
    debugPrint("🤙Cannot launch URL: $uriString");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exception: $e")),
    );
  }
}

// Rest of the classes remain unchanged
class ShopTabContent extends StatelessWidget {
  const ShopTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Check if we're near the bottom
        if (scrollInfo is ScrollEndNotification) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent * 0.7) {
            final state = context.read<AnotherUserProfileBloc>().state;
            if (!state.hasReachedEnd && !state.isLoadingMore) {
              context.read<AnotherUserProfileBloc>().add(
                    FetchPublications(
                      userId: state.profile?.id ?? '',
                    ),
                  );
            }
          }
        }
        return true;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                AppLocalizations.of(context)!.user_posts,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildProductsGrid(context),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return BlocBuilder<AnotherUserProfileBloc, AnotherUserProfileState>(
      builder: (context, state) {
        if (state.status == AnotherUserProfileStatus.loading &&
            state.publications.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AnotherUserProfileStatus.failure) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<AnotherUserProfileBloc>().add(
                            FetchPublications(
                              userId: state.profile?.id ?? '',
                              isInitialFetch: true,
                            ),
                          );
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                  if (state.errorMessage != null) Text(state.errorMessage!),
                ],
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
                    AppLocalizations.of(context)!.no_publications_available,
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
          padding: EdgeInsets.only(bottom: 16, left: 12, right: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Check if we need to load more
                if (index >= state.publications.length - 4 &&
                    !state.isLoadingMore &&
                    !state.hasReachedEnd) {
                  context.read<AnotherUserProfileBloc>().add(
                        FetchPublications(
                          userId: state.profile?.id ?? '',
                        ),
                      );
                }

                if (index == state.publications.length) {
                  if (state.isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return null;
                }

                final publication = state.publications[index];
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: ProductCardContainer(product: publication),
                );
              },
              childCount:
                  state.publications.length + (state.isLoadingMore ? 1 : 0),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 0.62,
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class AboutTabContent extends StatelessWidget {
  final AnotherUserProfileEntity user;

  const AboutTabContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Us Section Header
          Text(
            AppLocalizations.of(context)!.about_us,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // About Us Content (using biography field)
          Text(
            user.biography ??
                AppLocalizations.of(context)!.no_information_available,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          // Contact Information Section
          Text(
            AppLocalizations.of(context)!.contact_information,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          if (user.email != null)
            _buildInfoRow(CupertinoIcons.mail, user.email!),

          // Phone
          if (user.phoneNumber != null)
            _buildInfoRow(CupertinoIcons.phone, user.phoneNumber!),

          // Location
          if (user.locationName != null)
            _buildInfoRow(Icons.location_on_outlined, user.locationName!),

          const SizedBox(height: 30),

          // Available Hours Section
          if (user.fromTime != null && user.toTime != null) ...[
            Text(
              AppLocalizations.of(context)!.available_hours,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.access_time, '${user.fromTime} - ${user.toTime}'),
            const SizedBox(height: 8),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      final String phoneNumber = user.phoneNumber.toString();
                      _openTelegram(context, phoneNumber);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 24,
                          cornerSmoothing: 0.7,
                        ),
                      ),
                      backgroundColor: CupertinoColors.activeGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.write_to_telegram,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: Constants.Arial,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      _makeCall(context, "${user.phoneNumber}");
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        side: BorderSide(
                            width: 1,
                            color: CupertinoColors.activeGreen,
                            strokeAlign: BorderSide.strokeAlignCenter),
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 24,
                          cornerSmoothing: 0.7,
                        ),
                      ),
                      backgroundColor: CupertinoColors.white,
                      foregroundColor: CupertinoColors.activeGreen,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.call_now,
                      style: TextStyle(
                        fontFamily: Constants.Arial,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Member Since Info
          if (user.dateCreated != null)
            Center(
              child: Text(
                '${AppLocalizations.of(context)!.member_since}${_formatDate(user.dateCreated!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
