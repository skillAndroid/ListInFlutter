// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_state.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/details/presentation/widgets/follow_button.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/widgets/action_sheet_menu.dart';
import 'package:list_in/features/profile/presentation/widgets/delete_confirmation.dart';
import 'package:list_in/features/profile/presentation/widgets/info_dialog.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../bloc/details_event.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GetPublicationEntity product;
  final List<ProductEntity> recommendedProducts;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.recommendedProducts,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isMore = false;

  bool _isBottomButtonVisible = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    bool shouldShowBottomButton = info.visibleFraction < 0.1;

    if (_isBottomButtonVisible != shouldShowBottomButton) {
      setState(() {
        _isBottomButtonVisible = shouldShowBottomButton;
      });
    }
  }

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
  Widget build(BuildContext context) {
    final currentUserId = AppSession.currentUserId; // Get current user ID
    final isOwner =
        currentUserId == widget.product.seller.id; // Check if user is owner

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.containerColor,
        flexibleSpace: _buildTopBar(isOwner),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        ),
        child: _isBottomButtonVisible
            ? _buildBottomButtons(isOwner)
            : SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageSlider(),
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
        elevation: 4,
        shadowColor: AppColors.blue.withOpacity(0.25),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 1,
              ),
              Row(
                children: [
                  if (!isOwner) ...[
                    _buildTopBarButton(
                      icon: CupertinoIcons.doc_on_doc,
                      onTap: () {},
                    ),
                    _buildTopBarButton(
                      icon: CupertinoIcons.share,
                      onTap: () {},
                    ),
                    _buildTopBarButton(
                      icon: CupertinoIcons.ellipsis,
                      onTap: () {},
                    ),
                    BlocBuilder<GlobalBloc, GlobalState>(
                      builder: (context, state) {
                        final isLiked =
                            state.isPublicationLiked(widget.product.id);
                        final likeStatus =
                            state.getLikeStatus(widget.product.id);
                        final isLoading = likeStatus == LikeStatus.inProgress;

                        return SizedBox(
                          width: 40,
                          height: 40,
                          child: isLoading
                              ? Center(
                                  child: ShimmerEffect(
                                    isLiked: isLiked,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        isLiked
                                            ? AppIcons.favoriteBlack
                                            : AppIcons.favorite,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    if (!isLoading) {
                                      context.read<GlobalBloc>().add(
                                            UpdateLikeStatusEvent(
                                              publicationId: widget.product.id,
                                              isLiked: isLiked,
                                              context: context,
                                            ),
                                          );
                                    }
                                  },
                                  icon: Image.asset(
                                    isLiked
                                        ? AppIcons.favoriteBlack
                                        : AppIcons.favorite,
                                    width: 24,
                                    height: 24,
                                    color: isLiked
                                        ? AppColors.error
                                        : AppColors.black,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        );
                      },
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBottomButtons(bool isOwner) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            if (!isOwner) ...[
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.phoneCall,
                  label: 'Call',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    _makeCall(context, widget.product.seller.phoneNumber);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.messageSquare,
                  label: 'Message',
                  color: Colors.blue,
                  textColor: AppColors.white,
                  borderColor: AppColors.containerColor,
                  onPressed: () {/* Message logic */},
                ),
              ),
            ],
            if (isOwner) ...[
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.edit,
                  label: 'Edit',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    context
                        .read<PublicationUpdateBloc>()
                        .add(InitializePublication(widget.product));
                    context.push(
                      Routes.publicationsEdit,
                      extra: widget.product,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  icon: CupertinoIcons.delete,
                  label: 'Delete',
                  color: AppColors.error,
                  textColor: AppColors.white,
                  borderColor: AppColors.containerColor,
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
              ),
            ]
          ],
        ),
        //
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: SmoothClipRRect(
        smoothness: 0.8,
        borderRadius: BorderRadius.circular(13),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: SmoothClipRRect(
              smoothness: 0.9,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    final hasVideo = widget.product.videoUrl != null;
    final totalItems = hasVideo
        ? widget.product.productImages.length + 1
        : widget.product.productImages.length;

    return Stack(
      children: [
        Container(
          color: AppColors.containerColor,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
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
                          initialIndex: index, // Adjust index for video
                          heroTag: widget.product.id,
                          videoUrl: widget.product.videoUrl,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://${widget.product.productImages[imageIndex].url}',
                    fit: BoxFit
                        .cover, // Better than contain for most product images
                    filterQuality: FilterQuality
                        .high, // Balance between quality and performance
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.error_outline, color: Colors.red),
                    ),
                    cacheKey:
                        '${widget.product.id}_$imageIndex', // Unique cache key
                    useOldImageOnUrlChange:
                        true, // Show old image while loading new one
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
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Text(
                  '${_currentPage + 1} - $totalItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Divider(
            color: AppColors.black,
            height: 2,
          ),
        )
      ],
    );
  }

  Widget _buildMainContent(bool isOwner) {
    final enAttributes = widget.product.attributeValue.attributes['en'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrice(),
              if (isOwner) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppIcons.favorite,
                            width: 22,
                            height: 22,
                            color: AppColors.darkGray,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.product.likes.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),
                    // Views counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.eye,
                            size: 24,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.product.views.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
        _buildTitle(),
        const SizedBox(height: 8),
        //   InkWell(
        //       onTap: () {
        //         if (!isOwner) {
        //           context.push(Routes.anotherUserProfile, extra: {
        //             'userId': widget.product.seller.id,
        //           });
        //         } else {}
        //       },
        //       child: _buildLocation()),
        //  // _buildSellerInfo(),
        _buildCalMessageButtons(isOwner),
        const SizedBox(
          height: 8,
        ),
        _buildLocationInfo(isOwner),
        SizedBox(
          height: 4,
        ),
        if (enAttributes.isNotEmpty ||
            widget.product.attributeValue.numericValues.isNotEmpty)
          buildCharacteristics(enAttributes),
        SizedBox(
          height: 4,
        ),
        _buildDescription(),
        SizedBox(
          height: 16,
        ),
        _buildTrustAndSafety(),
        _buildBuyerProtection(),
        SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (!isOwner) {
                        context.push(Routes.anotherUserProfile, extra: {
                          'userId': widget.product.seller.id,
                        });
                      } else {}
                    },
                    child: _buildLocation(),
                  ),
                  _buildSellerInfo(),
                  if (!isOwner)
                    FollowButton(
                      userId: widget.product.seller.id,
                    ),
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 16),
                      child: Text(
                        'IT IS YOU',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: InkWell(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300], // Фон, если нет фото
                  child: widget.product.seller.profileImagePath != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://${widget.product.seller.profileImagePath!}', // Исправил ошибку в URL
                            fit: BoxFit.cover,
                            width: 64, // Диаметр 2 * radius
                            height: 64,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.red),
                          ),
                        )
                      : Icon(Icons.person, size: 32, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        _buildSimilarProducts(isOwner),
      ],
    );
  }

  Widget _buildSimilarProducts(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: InkWell(
            onTap: () {
              if (!isOwner) {
                context.push(Routes.anotherUserProfile, extra: {
                  'userId': widget.product.seller.id,
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOwner ? "Your post" : 'Other posts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.arrow_right_alt,
                  size: 44,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        buildProductsGrid(isOwner),
      ],
    );
  }

  Widget buildProductsGrid(bool isOwner) {
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
                  child: Text("Retry"),
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
                  'No publications available',
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
          padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
          child: GridView.builder(
            // If this grid is inside a ScrollView, you might want to set this to false
            shrinkWrap: true,
            // If this grid is inside a ScrollView, you might want to set this
            physics: ScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 0.599,
            ),
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
                  return const Center(child: CircularProgressIndicator());
                }
                return null;
              }

              final publication = state.publications[index];
              return Padding(
                padding: const EdgeInsets.all(0),
                child: ProductCardContainer(
                  product: publication,
                ),
              );
            },
          ),
        );
      },
    );
  }

// Modify the _buildLocationInfo() method in ProductDetailsScreen
  Widget _buildLocationInfo(bool isOwner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Text(
              widget.product.seller.locationName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
            ),
          ),
          InkWell(
            child: Text(
              'Show in map',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showLocationPrivacySheet(BuildContext context) {
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
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),

                // Title
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Location Privacy Enabled',
                    style: TextStyle(
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
                    'This seller has chosen to keep their exact location private. '
                    'This is a safety feature that helps protect our community members.\n\n'
                    'You can still see their approximate location area for delivery planning.',
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
                        title: 'Enhanced Safety',
                        description: 'Protects personal privacy and security',
                      ),
                      const SizedBox(height: 16),
                      _buildPrivacyPoint(
                        icon: Icons.location_on_outlined,
                        title: 'Area Visible',
                        description: 'General location area is still shown',
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
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Got it',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
              color: Colors.blue,
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

  Widget _buildShopInfo(bool isOwner) {
    bool isBusinessSeller = widget.product.seller.role == "BUSINESS_SELLER";
    bool isBargain = widget.product.bargain;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: AppColors.containerColor,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    isBusinessSeller ? 'Store' : 'Individual',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isBusinessSeller ? Icons.store : Icons.person_4,
                    size: 24,
                    color: isBusinessSeller ? Colors.green : Colors.blue,
                  ),
                  if (isBargain) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Bargain',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.handshake, size: 20, color: Colors.orange),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Text(
      "${formatPrice(widget.product.price.toString())} so'm",
      style: const TextStyle(
        height: 1.2,
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.seller.nickName,
        style: const TextStyle(
          fontSize: 24,
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                '5.0',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (widget.product.seller.rating != null) ...[
            RatingBarIndicator(
              rating: widget.product.seller.rating!,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 16,
            ),
          ],
          const SizedBox(width: 8),
          Text(
            '0 отзыв',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalMessageButtons(bool isOwner) {
    return VisibilityDetector(
      key: Key('cal_message_visibility'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            if (!isOwner) ...[
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.phoneCall,
                  label: 'Call',
                  color: CupertinoColors.activeGreen,
                  textColor: Colors.white,
                  onPressed: () {
                    _makeCall(context, widget.product.seller.phoneNumber);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.messageSquare,
                  label: 'Message',
                  color: Colors.blue,
                  textColor: AppColors.white,
                  borderColor: AppColors.containerColor,
                  onPressed: () {/* Message logic */},
                ),
              ),
            ],
            if (isOwner) ...[
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.edit,
                  label: 'Edit',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    context
                        .read<PublicationUpdateBloc>()
                        .add(InitializePublication(widget.product));
                    context.push(
                      Routes.publicationsEdit,
                      extra: widget.product,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  icon: CupertinoIcons.delete,
                  label: 'Delete',
                  color: AppColors.error,
                  textColor: AppColors.white,
                  borderColor: AppColors.containerColor,
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
              ),
            ]
          ],
        ),
        //
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.description,
            style: TextStyle(
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
    // Combine all features into a single list
    final List<MapEntry<String, String>> features = [];

    // Add regular attributes
    enAttributes.forEach((key, values) {
      if (values.isNotEmpty) {
        final value = values.length == 1 ? values[0] : values.join(', ');
        features.add(MapEntry(key, value));
      }
    });

    // Add numeric values
    for (var numericValue in widget.product.attributeValue.numericValues) {
      if (numericValue.numericValue.isNotEmpty) {
        features.add(
            MapEntry(numericValue.numericField, numericValue.numericValue));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Characteristics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          // Show first 5 items
          ...features.take(5).map((feature) => _buildCharacteristicItem(
                feature.key,
                feature.value,
              )),
          // Show "See All" button if there are more items
          if (features.length > 12)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: GestureDetector(
                onTap: () => _showAllCharacteristics(features),
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllCharacteristics(List<MapEntry<String, String>> features) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 700, // Set fixed height (adjust as needed)
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Characteristics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 600, // Fixed height for the list
              child: ListView(
                children: features
                    .map((feature) =>
                        _buildCharacteristicItem(feature.key, feature.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerProtection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Smaller height
          color: AppColors.containerColor,
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use verified payment methods and meet in safe locations to avoid scams.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustAndSafety() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.containerColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Safety',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Always check the item before buying. Avoid upfront payments without guarantees!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPublicationOptions(BuildContext context) {
    final options = [
      ActionSheetOption(
        title: 'Boost Publication',
        icon: CupertinoIcons.rocket,
        iconColor: AppColors.primary,
        onPressed: () => _showBoostUnavailableMessage(context),
      ),
      ActionSheetOption(
        title: 'Delete Publication',
        icon: CupertinoIcons.delete,
        iconColor: AppColors.error,
        onPressed: () => _showDeleteConfirmation(context),
        isDestructive: true,
      ),
    ];

    ActionSheetMenu.show(
      context: context,
      title: 'Publication Options',
      message: 'Choose an action for this publication',
      options: options,
    );
  }

  void _showDeleteConfirmation(BuildContext context) async {
    final shouldDelete = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Publication',
      message:
          'Are you sure you want to delete this publication? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructiveAction: true,
    );

    if (shouldDelete) {
      context.read<UserPublicationsBloc>().add(
            DeleteUserPublication(publicationId: widget.product.id),
          );
      context.pop();
    }
  }

  void _showBoostUnavailableMessage(BuildContext context) {
    InfoDialog.show(
      context: context,
      title: 'Boost Unavailable',
      message:
          'Publication boosting is a premium feature that is not yet supported. Stay tuned for updates!',
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
                child: const Text(
                  'Map',
                  style: TextStyle(
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
