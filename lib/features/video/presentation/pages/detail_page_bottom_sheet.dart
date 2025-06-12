// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/presentation/pages/chat_detail_page.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_event.dart';
import 'package:list_in/features/details/presentation/bloc/details_state.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/details/presentation/widgets/full_screen_map.dart';
import 'package:list_in/features/details/presentation/widgets/product_char_widget.dart';
import 'package:list_in/features/details/presentation/widgets/product_description.dart';
import 'package:list_in/features/details/presentation/widgets/product_price.dart';
import 'package:list_in/features/details/presentation/widgets/product_title.dart'
    show ProductTitleWidget;
import 'package:list_in/features/details/presentation/widgets/production_action_service.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/product_card_container.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final GetPublicationEntity product;

  const ProductDetailsBottomSheet({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  late final DetailsPageUIState _uiState;
  final PageController _pageController = PageController();
  final ScrollController _thumbnailScrollController = ScrollController();
  int _currentPage = 0;
  bool isMore = false;

  @override
  void initState() {
    super.initState();
    _uiState = DetailsPageUIState();

    // Fixed the syntax error here - was using pageController instead of _pageController

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
    _uiState.dispose();
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
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildImageSlider(isOwner),
                        _buildMainContent(isOwner, currentUserId!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(bool isOwner) {
    final totalItems = widget.product.productImages.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).cardColor,
                child: AspectRatio(
                  aspectRatio: 4 / 5.75,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      if (_thumbnailScrollController.hasClients) {
                        final thumbnailHeight = 80.0 + 8.0;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final offset = index * thumbnailHeight -
                            (screenHeight / 4) +
                            (thumbnailHeight / 2);

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
                      // Show regular images after video
                      final imageIndex = index;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductImagesDetailed(
                                  images: widget.product.productImages,
                                  initialIndex: imageIndex,
                                  heroTag: widget.product.id,
                                  videoUrl: widget.product.videoUrl,
                                ),
                              ));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 0,
                            left: 0,
                          ),
                          child: SmoothClipRRect(
                            smoothness: 0.8,
                            borderRadius: BorderRadius.circular(0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Blurred background layer
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                      sigmaX: 100, sigmaY: 100),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://${widget.product.productImages[imageIndex].url}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),

                                // Main image layer (centered and contained)
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://${widget.product.productImages[imageIndex].url}',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Back button - top left
              Positioned(
                top: 32,
                left: 16,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Progress indicator at bottom
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Image counter text with fade transition
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Text(
                          '${_currentPage + 1} / $totalItems',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Progress indicators with animated transitions
                      SizedBox(
                        height: 8.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            totalItems,
                            (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _currentPage == index ? 24.0 : 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index
                                    ? AppColors.black
                                    : Colors.white.withOpacity(0.6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Like button
              BlocBuilder<GlobalBloc, GlobalState>(
                builder: (context, state) {
                  final isLiked = state.isPublicationLiked(widget.product.id);
                  final likeStatus = state.getLikeStatus(widget.product.id);

                  return OptimizedLikeButton(
                    productId: widget.product.id,
                    likes: widget.product.likes,
                    isOwner: isOwner,
                    isLiked: isLiked,
                    likeStatus: likeStatus,
                    size: 45,
                    bootom: 10,
                    right: 16,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

// Modified _buildMainContent to include the vertical grid
  Widget _buildMainContent(bool isOwner, String userId) {
    final localizations = AppLocalizations.of(context)!;
    final enAttributes = widget.product.attributeValue.attributes['en'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ProductTitleWidget(product: widget.product),
        const SizedBox(height: 8),

        // Seller Profile Row with Actions
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: InkWell(
                  onTap: () {
                    if (!isOwner) {
                      context.push(Routes.anotherUserProfile, extra: {
                        'userId': widget.product.seller.id,
                      });
                    }
                  },
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://${widget.product.seller.profileImagePath}',
                      fit: BoxFit.cover,
                      width: 38,
                      height: 38,
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
                  }
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
                          fontSize: 14,
                          height: 1,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.product.seller.rating} ${localizations.rating} (0 ${localizations.reviews}) ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Follow button for non-owners
            if (!isOwner)
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
                      height: 30,
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
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: isLoading
                            ? Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
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
                                    size: 14,
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
                                      fontSize: 13,
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

        // Price widget
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProductPriceWidget(product: widget.product),
            ],
          ),
        ),

        // Location widget
        InkWell(
          onTap: () {
            if (widget.product.isGrantedForPreciseLocation) {
              Navigator.of(context).push(
                CupertinoModalPopupRoute(
                  builder: (context) {
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
            padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.product.locationName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.location,
                  color: Theme.of(context).iconTheme.color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        // Condition row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.condition,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              Text(
                localizations.condition_new,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Row(
              children: [
                // Primary action - In-app Chat button (now main)
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            userId: userId,
                            recipientId: widget.product.seller.id,
                            publicationId: widget.product.id,
                            publicationTitle: widget.product.title,
                            recipientName: widget.product.seller.nickName,
                            publicationImagePath:
                                'https://${widget.product.productImages[0].url}',
                            userProfileImage:
                                'https://${widget.product.seller.profileImagePath}',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(
                      Ionicons.chatbubble_ellipses,
                      size: 20,
                      color: AppColors.white,
                    ),
                    label: Text(
                      localizations.write,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                        fontFamily: Constants.Arial,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Modern secondary action - More options with animated popup
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 1,
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'telegram':
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

                          final String phoneNumber =
                              widget.product.seller.phoneNumber;
                          ProductActionsService.openTelegram(
                              context, message, phoneNumber);
                          break;
                        case 'call':
                          ProductActionsService.makeCall(
                            context,
                            widget.product.seller.phoneNumber,
                          );
                          break;
                      }
                    },
                    position: PopupMenuPosition.under,
                    offset: const Offset(0, 6),
                    elevation: 2,
                    surfaceTintColor: Colors.transparent,
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Theme.of(context).cardColor,
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 24,
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'telegram',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF26A5E4)
                                        .withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.telegram_rounded,
                                    color: Color(0xFF26A5E4),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  localizations.write_to_telegram,
                                  style: const TextStyle(
                                    fontFamily: Constants.Arial,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'call',
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.phone_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  localizations.call_now,
                                  style: const TextStyle(
                                    fontFamily: Constants.Arial,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (isOwner) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<PublicationUpdateBloc>()
                          .add(InitializePublication(widget.product));
                      context.push(Routes.publicationsEdit,
                          extra: widget.product);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      localizations.edit_post,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.Arial,
                        color: AppColors.white,
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
                          context, widget.product.id);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        side: BorderSide(
                            width: 1,
                            color: Theme.of(context).cardColor,
                            strokeAlign: BorderSide.strokeAlignCenter),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      localizations.delete,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.Arial,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 16),

        // Product characteristics
        if (enAttributes.isNotEmpty ||
            widget.product.attributeValue.numericValues.isNotEmpty) ...[
          ProductCharacteristicsWidget(product: widget.product),
          SizedBox(height: 8),
        ],

        // Product description
        ProductDescriptionWidget(product: widget.product),

        // Vertical grid of similar products
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: BlocBuilder<DetailsBloc, DetailsState>(
            builder: (context, state) {
              if (state.status == DetailsStatus.loading &&
                  state.publications.isEmpty) {
                return Center(child: Progress());
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.inventory,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          localizations.no_publications_available,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return MasonryGridView.builder(
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                shrinkWrap:
                    true, // Important for working with parent ScrollView
                itemCount:
                    state.publications.length + (state.isLoadingMore ? 1 : 0),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 1.5,
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
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return SizedBox();
                  }
                  // Determine if item should use advertised card based on video URL
                  final bool isAdvertised =
                      state.publications[index].videoUrl != null;
                  final publication = state.publications[index];
                  return isAdvertised
                      ? _buildAdvertisedProduct(
                          publication,
                        )
                      : ProductCardContainer(
                          product: publication,
                        );
                },
              );
            },
          ),
        ),

        // Bottom padding
        SizedBox(height: 16),
      ],
    );
  }

  void _handleVisibilityChanged(String id, double visibilityFraction) {
    if (_uiState.getVisibility(id) != visibilityFraction) {
      _uiState.updateVisibility(id, visibilityFraction);
      _updateMostVisibleVideo();
    }
  }

  void _updateMostVisibleVideo() {
    String? mostVisibleId;
    double maxVisibility = 0.0;

    _uiState.visibilityNotifiers.forEach((id, notifier) {
      final visibility = notifier.value;
      final currentPage = _uiState.getPage(id);

      if (visibility > maxVisibility && currentPage == 0 && visibility > 0.6) {
        maxVisibility = visibility;
        mostVisibleId = id;
      }
    });

    if (mostVisibleId != _uiState.currentlyPlayingId.value) {
      _uiState.currentlyPlayingId.value = mostVisibleId;
    }
  }

  Widget _buildAdvertisedProduct(GetPublicationEntity product) {
    _uiState.ensureProductTrackers(product.id);

    return ValueListenableBuilder<double>(
      valueListenable: _uiState.visibilityNotifiers[product.id]!,
      builder: (context, visibility, _) {
        return VisibilityDetector(
          key: Key('detector_${product.id}'),
          onVisibilityChanged: (info) => _handleVisibilityChanged(
            product.id,
            info.visibleFraction,
          ),
          child: OptimizedAdvertisedCard(
            product: product,
            currentlyPlayingId: _uiState.currentlyPlayingId,
          ),
        );
      },
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
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    textAlign: TextAlign.center,
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
                        backgroundColor: AppColors.primary,
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
              color: AppColors.primary,
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
