// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_state.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/widgets/action_sheet_menu.dart';
import 'package:list_in/features/profile/presentation/widgets/info_dialog.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/details_event.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GetPublicationEntity product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final ScrollController _thumbnailScrollController = ScrollController();
  int _currentPage = 0;
  bool isMore = false;

  @override
  void initState() {
    super.initState();
    final globalBloc = context.read<GlobalBloc>();
    final currentUserId = globalBloc.getUserId(); // Get current user ID
    final isOwner =
        currentUserId == widget.product.seller.id; // Check if user is owner

    if (!isOwner) {
      context.read<DetailsBloc>().add(
            FetchPublications(
              userId: widget.product.seller.id,
              isInitialFetch: true,
            ),
          );
    }

    if (!isOwner) {
      final isViewed = globalBloc.state.isPublicationViewed(widget.product.id);
      if (!isViewed) {
        globalBloc.add(
          UpdateViewStatusEvent(
            publicationId: widget.product.id,
            isViewed: true,
            context: context,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AppSession.currentUserId; // Get current user ID
    final isOwner =
        currentUserId == widget.product.seller.id; // Check if user is owner

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgColor,
        flexibleSpace: _buildTopBar(isOwner),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageSlider(isOwner),
                      _buildMainContent(isOwner),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isOwner) {
    return SafeArea(
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 0,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  )
                ],
              ),
              SizedBox(
                width: 1,
              ),
              Row(
                children: [
                  if (!isOwner) ...[
                    _buildTopBarButton(
                      icon: CupertinoIcons.share,
                      onTap: () {},
                    ),
                    _buildTopBarButton(
                      icon: CupertinoIcons.ellipsis,
                      onTap: () {},
                    ),
                  ],
                  if (isOwner) ...[
                    IconButton(
                      onPressed: () {
                        context
                            .read<PublicationUpdateBloc>()
                            .add(InitializePublication(widget.product));
                        context.push(
                          Routes.publicationsEdit,
                          extra: widget.product,
                        );
                      },
                      icon: Icon(
                        color: AppColors.primary,
                        EvaIcons.edit,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showPublicationOptions(context);
                      },
                      icon: Icon(
                        Ionicons.ellipsis_vertical,
                        color: AppColors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      width: 40,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildImageSlider(bool isOwner) {
    final hasVideo = widget.product.videoUrl != null;
    final totalItems = hasVideo
        ? widget.product.productImages.length + 1
        : widget.product.productImages.length;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              color: AppColors.white,
              child: AspectRatio(
                aspectRatio: 4 / 4.6,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);

                    // Auto-scroll the thumbnail strip to center the current thumbnail
                    if (_thumbnailScrollController.hasClients) {
                      final thumbnailWidth = 76.0 + 3.6; // width + padding
                      final screenWidth = MediaQuery.of(context).size.width;
                      final offset = index * thumbnailWidth -
                          (screenWidth / 2) +
                          (thumbnailWidth / 2);

                      // Ensure the offset is within bounds
                      final maxScroll =
                          _thumbnailScrollController.position.maxScrollExtent;
                      final scrollOffset = offset.clamp(0.0, maxScroll);

                      // Animate to the new position
                      _thumbnailScrollController.animateTo(
                        scrollOffset,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    // Show video thumbnail as first item if video exists
                    if (hasVideo && index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl: widget.product.videoUrl!,
                                thumbnailUrl:
                                    'https://${widget.product.productImages[0].url}',
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  'https://${widget.product.productImages[0].url}',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                            Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show regular images after video
                    final imageIndex = hasVideo ? index - 1 : index;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductImagesDetailed(
                              images: widget.product.productImages,
                              initialIndex: index,
                              heroTag: widget.product.id,
                              videoUrl: widget.product.videoUrl,
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://${widget.product.productImages[imageIndex].url}',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.error_outline,
                              color: Colors.red),
                        ),
                        cacheKey: '${widget.product.id}_$imageIndex',
                        useOldImageOnUrlChange: true,
                        fadeOutDuration: const Duration(milliseconds: 100),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 8,
              child: Center(
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Text(
                      '${_currentPage + 1} of $totalItems',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              right: 8,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                color: AppColors.containerColor,
                shadowColor: AppColors.error.withOpacity(0.3),
                elevation: 4,
                child: BlocBuilder<GlobalBloc, GlobalState>(
                  builder: (context, state) {
                    final isLiked = state.isPublicationLiked(widget.product.id);
                    final likeStatus = state.getLikeStatus(widget.product.id);
                    final isLoading = likeStatus == LikeStatus.inProgress;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: isLoading
                                ? Center(
                                    child: ShimmerEffect(
                                      isLiked: isLiked,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          isLiked
                                              ? AppIcons.favoriteBlack
                                              : AppIcons.favorite,
                                          width: 22,
                                          height: 22,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      if (!isOwner) {
                                        if (!isLoading) {
                                          context.read<GlobalBloc>().add(
                                                UpdateLikeStatusEvent(
                                                  publicationId:
                                                      widget.product.id,
                                                  isLiked: isLiked,
                                                  context: context,
                                                ),
                                              );
                                        }
                                      }
                                    },
                                    icon: Image.asset(
                                      isLiked
                                          ? AppIcons.favoriteBlack
                                          : AppIcons.favorite,
                                      width: 26,
                                      height: 26,
                                      color: isLiked
                                          ? AppColors.error
                                          : AppColors.black,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
        // Thumbnail strip with auto-scrolling functionality
        Container(
          height: 98,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: ListView.builder(
              controller: _thumbnailScrollController, // Add the controller here
              scrollDirection: Axis.horizontal,
              itemCount: totalItems,
              itemBuilder: (context, index) {
                final bool isSelected = index == _currentPage;
                final imageIndex = hasVideo && index > 0 ? index - 1 : index;

                return Padding(
                  padding: const EdgeInsets.all(1.2),
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: SmoothClipRRect(
                      smoothness: 0.8,
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.black : Colors.transparent,
                        width: 2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: SizedBox(
                          width: 74,
                          child: SmoothClipRRect(
                            smoothness: 0.8,
                            borderRadius: BorderRadius.circular(10),
                            child: hasVideo && index == 0
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            'https://${widget.product.productImages[0].url}',
                                        fit: BoxFit.cover,
                                      ),
                                      Center(
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : CachedNetworkImage(
                                    imageUrl:
                                        'https://${widget.product.productImages[imageIndex].url}',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isOwner) {
    final localizations = AppLocalizations.of(context)!;
    final enAttributes = widget.product.attributeValue.attributes['en'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 3,
        ),
        _buildTitle(),
        const SizedBox(
          height: 14,
        ),
        // Seller Profile Row with Actions
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 8,
              ),
              child: InkWell(
                  onTap: () {
                    if (!isOwner) {
                      context.push(Routes.anotherUserProfile, extra: {
                        'userId': widget.product.seller.id,
                      });
                    } else {}
                  },
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://${widget.product.seller.profileImagePath}',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Image.asset(AppImages.appLogo),
                    ),
                  )),
            ),

            // Seller Info with Follow Button
            Expanded(
              child: InkWell(
                onTap: () {
                  if (!isOwner) {
                    context.push(Routes.anotherUserProfile, extra: {
                      'userId': widget.product.seller.id,
                    });
                  } else {}
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.product.seller.nickName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.product.seller.rating} ${localizations.rating} (0 ${localizations.reviews}) ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isOwner)

              // Message Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<GlobalBloc, GlobalState>(
                  builder: (context, state) {
                    final isFollowed =
                        state.isUserFollowed(widget.product.seller.id);
                    final followStatus =
                        state.getFollowStatus(widget.product.seller.id);
                    final isLoading = followStatus == FollowStatus.inProgress;
                    return Container(
                      margin: EdgeInsets.only(top: 0),
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<GlobalBloc>().add(
                                      UpdateFollowStatusEvent(
                                        userId: widget.product.seller.id,
                                        isFollowed: isFollowed,
                                        context: context,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: SmoothRectangleBorder(
                            side: BorderSide(width: 1, color: AppColors.black),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFollowed ? Icons.remove : Icons.add,
                                    size: 16,
                                    color: AppColors.black,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    isFollowed
                                        ? localizations.unfollow
                                        : localizations.follow,
                                    style: TextStyle(
                                      fontFamily: Constants.Arial,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrice(),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            if (widget.product.isGrantedForPreciseLocation) {
              debugPrint(
                  "🗺️ BEFORE MAP NAVIGATION - Location name: ${widget.product.locationName}");
              debugPrint(
                  "📍 BEFORE MAP NAVIGATION - Latitude: ${widget.product.latitude}");
              debugPrint(
                  "📍 BEFORE MAP NAVIGATION - Longitude: ${widget.product.longitude}");

              Navigator.of(context).push(
                CupertinoModalPopupRoute(
                  builder: (context) {
                    // Additional debug inside the builder function
                    debugPrint(
                        "🚀 LAUNCHING MAP - Location name: ${widget.product.locationName}");
                    debugPrint(
                        "🌍 LAUNCHING MAP - Latitude: ${widget.product.latitude}");
                    debugPrint(
                        "🌍 LAUNCHING MAP - Longitude: ${widget.product.longitude}");

                    return FullScreenMap(
                      locationName: widget.product.locationName,
                      latitude: widget.product.longitude!,
                      longitude: widget.product.latitude!,
                    );
                  },
                ),
              );
            } else {
              showLocationPrivacySheet(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 24, 12),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.product.locationName,
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Включает перенос на новую строку
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.location,
                  color: AppColors.black,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.condition,
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                localizations.condition_new,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                localizations.condition_used,
                style: TextStyle(
                  color: AppColors.transparent,
                ),
              ),
            ],
          ),
        ),
        if (!isOwner) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      backgroundColor: CupertinoColors.activeGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      localizations.write_to_telegram,
                      style: const TextStyle(
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
            padding: const EdgeInsets.fromLTRB(16, 3, 16, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      _makeCall(context, widget.product.seller.phoneNumber);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        side: BorderSide(
                            width: 1,
                            color: CupertinoColors.activeGreen,
                            strokeAlign: BorderSide.strokeAlignCenter),
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      backgroundColor: CupertinoColors.white,
                      foregroundColor: CupertinoColors.activeGreen,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      localizations.call_now,
                      style: const TextStyle(
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
        ],

        if (isOwner) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<PublicationUpdateBloc>()
                          .add(InitializePublication(widget.product));
                      context.push(
                        Routes.publicationsEdit,
                        extra: widget.product,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      backgroundColor: CupertinoColors.activeGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      localizations.edit_post,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        side: BorderSide(
                            width: 1,
                            color: CupertinoColors.activeGreen,
                            strokeAlign: BorderSide.strokeAlignCenter),
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      backgroundColor: CupertinoColors.white,
                      foregroundColor: CupertinoColors.activeGreen,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      localizations.delete,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          height: 24,
        ),
        if (enAttributes.isNotEmpty ||
            widget.product.attributeValue.numericValues.isNotEmpty) ...[
          buildCharacteristics(enAttributes),
          SizedBox(
            height: 12,
          ),
        ],

        _buildDescription(),
        SizedBox(
          height: 16,
        ),
        _buildSimilarProducts(isOwner),
      ],
    );
  }

  void showLocationPrivacySheet(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SmoothClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar at top
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Privacy Icon
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: CupertinoColors.activeGreen,
                    size: 32,
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    localizations.location_privacy_enabled,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    localizations.location_privacy_description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),

                // Privacy Points
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildPrivacyPoint(
                        icon: Icons.shield_outlined,
                        title: localizations.enhanced_safety,
                        description: localizations.protects_privacy,
                      ),
                      const SizedBox(height: 16),
                      _buildPrivacyPoint(
                        icon: Icons.location_on_outlined,
                        title: localizations.area_visible,
                        description: localizations.general_location_shown,
                      ),
                    ],
                  ),
                ),

                // Got it button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      24, 0, 24, MediaQuery.of(context).padding.bottom + 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: CupertinoColors.activeGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        localizations.got_it,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: Constants.Arial,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        SmoothClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Icon(
              icon,
              color: CupertinoColors.activeGreen,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    final localizations = AppLocalizations.of(context)!;
    return Text.rich(
      TextSpan(
        text: "${formatPrice(widget.product.price.toString())} ", // Main price
        style: const TextStyle(
          fontSize: 26,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
          fontFamily: Constants.Arial,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: localizations.currency, // Currency text
            style: TextStyle(
              fontSize: 18, // Smaller font size
              fontWeight: FontWeight.w400, // Lighter weight
              color: AppColors.darkGray,
              fontFamily: Constants.Arial,
              // Brighter color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.description,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: const TextStyle(
              color: AppColors.darkBackground,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCharacteristics(Map<String, List<String>> enAttributes) {
    // Get the current language code
    return BlocSelector<LanguageBloc, LanguageState, String>(
        selector: (state) =>
            state is LanguageLoaded ? state.languageCode : AppLanguages.english,
        builder: (context, languageCode) {
          final localizations = AppLocalizations.of(context)!;

          // Combine all features into a single list
          final List<MapEntry<String, String>> features = [];

          // Add attributes for the current language
          final attributes =
              widget.product.attributeValue.attributes[languageCode] ??
                  widget.product.attributeValue.attributes['en'] ??
                  {};

          attributes.forEach((key, values) {
            if (values.isNotEmpty) {
              final value = values.length == 1 ? values[0] : values.join(', ');
              features.add(MapEntry(key, value));
            }
          });

          // Add numeric values
          for (var numericValue
              in widget.product.attributeValue.numericValues) {
            if (numericValue.numericValue.isNotEmpty) {
              // Get localized field name based on language
              final fieldName = getLocalizedText(
                numericValue.numericField,
                numericValue.numericFieldUz,
                numericValue.numericFieldRu,
                languageCode,
              );
              features.add(MapEntry(fieldName, numericValue.numericValue));
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.about_this_item,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBackground,
                  ),
                ),
                const SizedBox(height: 8),
                // Show all items
                ...features.map((feature) => _buildCharacteristicItem(
                      feature.key,
                      feature.value,
                    )),
              ],
            ),
          );
        });
  }

  Widget _buildCharacteristicItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '$label: ',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPublicationOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final options = [
      ActionSheetOption(
        title: localizations.boost_publication,
        icon: CupertinoIcons.rocket,
        iconColor: AppColors.primary,
        onPressed: () => _showBoostUnavailableMessage(context),
      ),
      ActionSheetOption(
        title: localizations.delete_publication,
        icon: CupertinoIcons.delete,
        iconColor: AppColors.error,
        onPressed: () => _showDeleteConfirmation(context),
        isDestructive: true,
      ),
    ];

    ActionSheetMenu.show(
      context: context,
      title: localizations.publication_options,
      message: localizations.choose_action,
      options: options,
    );
  }

  void _showDeleteConfirmation(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: Text(localizations.delete_publication),
              content: Text(
                localizations.delete_confirmation,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text(localizations.delete),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      context.read<UserPublicationsBloc>().add(
            DeleteUserPublication(publicationId: widget.product.id),
          );
      context.pop();
    }
  }

  void _showBoostUnavailableMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    InfoDialog.show(
      context: context,
      title: localizations.boost_unavailable,
      message: localizations.boost_unavailable_description,
    );
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
              content:
                  Text("Error: Unable to launch call to $cleanPhoneNumber")),
        );
      }
    } catch (e) {
      debugPrint("🤙Cannot launch URL: $uriString");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  Widget _buildSimilarProducts(bool isOwner) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isOwner ? localizations.your_post : localizations.user_other_posts,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        buildProductsGrid(isOwner),
      ],
    );
  }

  Widget buildProductsGrid(bool isOwner) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        if (state.status == DetailsStatus.loading &&
            state.publications.isEmpty) {
          return Progress();
        }
        if (state.status == DetailsStatus.failure &&
            state.publications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<DetailsBloc>().add(
                          FetchPublications(
                            userId: state.profile?.id ?? '',
                            isInitialFetch: true,
                          ),
                        );
                  },
                  child: Text(localizations.retry),
                ),
                if (state.errorMessage != null) Text(state.errorMessage!),
              ],
            ),
          );
        }
        if (state.publications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.inventory, size: 72, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  localizations.no_publications_available,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 24, left: 0),
          child: SizedBox(
            height: 300, // Adjust height based on your product card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount:
                  state.publications.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Check if we need to load more
                if (index >= state.publications.length - 4 &&
                    !state.isLoadingMore &&
                    !state.hasReachedEnd) {
                  context.read<DetailsBloc>().add(
                        FetchPublications(
                          userId: state.profile?.id ?? '',
                        ),
                      );
                }

                if (index == state.publications.length) {
                  if (state.isLoadingMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return null;
                }

                final publication = state.publications[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 4),
                  child: SizedBox(
                    width: 180, // Adjust width based on your design
                    child: ProductCardContainer(
                      product: publication,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FullScreenMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const FullScreenMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  Future<void> _openInMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56),
          child: CustomLocationHeader(
            locationName: locationName,
            onBackPressed: () => Navigator.pop(context),
            onMapsPressed: _openInMaps,
            elevation: 2,
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          )),
      body: GoogleMap(
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: locationName),
          ),
        },
      ),
    );
  }
}

class CustomLocationHeader extends StatelessWidget {
  final String locationName;
  final VoidCallback onBackPressed;
  final VoidCallback onMapsPressed;
  final double elevation;
  final Color backgroundColor;
  final EdgeInsets padding;

  const CustomLocationHeader({
    super.key,
    required this.locationName,
    required this.onBackPressed,
    required this.onMapsPressed,
    this.elevation = 1,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      margin: EdgeInsets.zero,
      elevation: elevation,
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                onPressed: onBackPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),

              // Location Section
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        locationName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 16,
              ),

              // Maps Button
              TextButton(
                onPressed: onMapsPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  localizations.map,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
