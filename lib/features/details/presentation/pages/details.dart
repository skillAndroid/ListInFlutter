// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/details/presentation/widgets/full_screen_map.dart';
import 'package:list_in/features/details/presentation/widgets/product_char_widget.dart';
import 'package:list_in/features/details/presentation/widgets/product_description.dart';
import 'package:list_in/features/details/presentation/widgets/product_price.dart';
import 'package:list_in/features/details/presentation/widgets/product_title.dart'
    show ProductTitleWidget;
import 'package:list_in/features/details/presentation/widgets/production_action_service.dart';
import 'package:list_in/features/details/presentation/widgets/products_grid_details_pade.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary,
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
                        ProductActionsService.showPublicationOptions(
                          context,
                          widget.product,
                        );
                      },
                      icon: Icon(
                        Ionicons.ellipsis_vertical,
                        color: Theme.of(context).colorScheme.secondary,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Theme.of(context).iconTheme.color,
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
              color: Theme.of(context).cardColor.withOpacity(0.0),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary
                                      .withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Theme.of(context).iconTheme.color,
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.5),
                    ),
                    child: Text(
                      '${_currentPage + 1} of $totalItems',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
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
                color: Theme.of(context).cardColor,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.transparent,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary
                                                .withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.play_arrow_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
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
        ProductTitleWidget(
          product: widget.product,
        ),
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
                            color: Theme.of(context).colorScheme.secondary,
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
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.product.seller.rating} ${localizations.rating} (0 ${localizations.reviews}) ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
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
                          backgroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                          elevation: 0,
                          shape: SmoothRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        child: isLoading
                            ? Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
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
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    isFollowed
                                        ? localizations.unfollow
                                        : localizations.follow,
                                    style: TextStyle(
                                      fontFamily: Constants.Arial,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
              ProductPriceWidget(product: widget.product),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 24, 8),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.product.locationName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.condition,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                localizations.condition_new,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
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
                    onPressed: () {
                      // Create greeting message based on language with product details
                      final String languageCode =
                          Localizations.localeOf(context).languageCode;
                      String message;

                      switch (languageCode) {
                        case 'uz':
                          message =
                              "Salom! Men sizning \"${widget.product.title}\" e'loningiz bilan qiziqyapman. Narxi: ${widget.product.price} so'm. Shu mahsulot hali sotuvda bormi?";
                          break;
                        case 'en':
                          message =
                              "Hello! I'm interested in your listing \"${widget.product.title}\". Price: ${widget.product.price}. Is this item still available?";
                          break;
                        case 'ru':
                        default:
                          message =
                              "Здравствуйте! Меня интересует ваше объявление \"${widget.product.title}\". Цена: ${widget.product.price}. Этот товар еще доступен?";
                          break;
                      }

                      // Get seller phone number from the product entity
                      final String phoneNumber =
                          widget.product.seller.phoneNumber;
                      ProductActionsService.openTelegram(
                        context,
                        message,
                        phoneNumber,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      backgroundColor: CupertinoColors.activeGreen,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      localizations.write_to_telegram,
                      style: TextStyle(
                        fontSize: 17,
                        //  color: Theme.of(context).colorScheme.secondary,
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
                      ProductActionsService.makeCall(
                        context,
                        widget.product.seller.phoneNumber,
                      );
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
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondary,
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
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
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
                      ProductActionsService.showDeleteConfirmation(
                        context,
                        widget.product.id,
                      );
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
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondary,
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
          ProductCharacteristicsWidget(product: widget.product),
          SizedBox(
            height: 12,
          ),
        ],

        ProductDescriptionWidget(
          product: widget.product,
        ),
        SizedBox(
          height: 16,
        ),
        ProductsGridWidget(
          isOwner: isOwner,
        )
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
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
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
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
}
