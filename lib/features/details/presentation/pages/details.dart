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
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
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
    context.read<DetailsBloc>().add(
          FetchPublications(
            userId: widget.product.seller.id,
            isInitialFetch: true,
          ),
        );

    final globalBloc = context.read<GlobalBloc>();
    final currentUserId = globalBloc.getUserId(); // Get current user ID
    final isOwner =
        currentUserId == widget.product.seller.id; // Check if user is owner

    // Only update view status if the user is not the owner
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
    final globalBloc = context.read<GlobalBloc>();
    final currentUserId = globalBloc.getUserId(); // Get current user ID
    final isOwner =
        currentUserId == widget.product.seller.id; // Check if user is owner

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
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
                                        ? AppColors.primary
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
                        context.push(
                          Routes.publicationsEdit,
                          extra: widget.product.convertToPublicationEntity(),
                        );
                      },
                      icon: Icon(
                        color: AppColors.primary,
                        EvaIcons.edit,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Show delete confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Publication'),
                            content: const Text(
                                'Are you sure you want to delete this publication?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Implement delete logic
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        CupertinoIcons.delete_solid,
                        color: AppColors.error,
                        size: 22,
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
                  onPressed: () {/* Call logic */},
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
                    context.push(
                      Routes.publicationsEdit,
                      extra: widget.product.convertToPublicationEntity(),
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
                  onPressed: () {/* Message logic */},
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
        smoothness: 0.9,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: SmoothClipRRect(
              smoothness: 0.9,
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: borderColor ?? AppColors.transparent),
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
                    fit: BoxFit.contain,
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
        const SizedBox(height: 12),
        _buildShopInfo(isOwner),
        const SizedBox(height: 20),
        InkWell(
            onTap: () {
              if (!isOwner) {
                context.push(Routes.anotherUserProfile, extra: {
                  'userId': widget.product.seller.id,
                });
              } else {}
            },
            child: _buildLocation()),
        _buildSellerInfo(),
        _buildCalMessageButtons(isOwner),
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
              childAspectRatio: 0.64,
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
                child: RemouteRegularProductCard2(
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
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.seller.locationName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.blue,
                size: 19,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  children: [
                    const TextSpan(
                      text: "Working hours: ",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                    TextSpan(
                      text:
                          "${widget.product.seller.fromTime} - ${widget.product.seller.toTime}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FullScreenMap(
                    latitude: widget.product.latitude!,
                    longitude: widget.product.longitude!,
                    locationName: widget.product.seller.locationName,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutQuart;

                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_right_alt,
                  color: Colors.blue,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Show in map',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      "${formatPrice(widget.product.price.toString())} Uz",
      style: const TextStyle(
        height: 1.2,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.seller.nickName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            'Created: ${DateFormat('dd MMMM yyyy').format(widget.product.seller.dateCreated)}',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
            ),
          ),
        ],
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
              itemSize: 18,
            ),
          ],
          const SizedBox(width: 8),
          Text(
            '0 отзыв',
            style: TextStyle(
              color: Colors.grey[600],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (!isOwner) ...[
              Expanded(
                child: _buildButton(
                  icon: EvaIcons.phoneCall,
                  label: 'Call',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {/* Call logic */},
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
                    context.push(
                      Routes.publicationsEdit,
                      extra: widget.product.convertToPublicationEntity(),
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
                  onPressed: () {/* Message logic */},
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
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.description,
            maxLines: isMore == true ? 100 : 5,
            style: TextStyle(
              color: AppColors.darkBackground,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          TextButton(
            onPressed: () {
              if (isMore) {
                setState(() {
                  isMore = false;
                });
              } else {
                setState(() {
                  isMore = true;
                });
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isMore == true ? "Less" : 'More',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                  fontFamily: "Poppins"),
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
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Show first 5 items
          ...features.take(5).map((feature) => _buildCharacteristicItem(
                feature.key,
                feature.value,
              )),
          // Show "See All" button if there are more items
          if (features.length > 5)
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
                fontSize: 26,
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          locationName,
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
      ),
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
            markerId: MarkerId('selectedLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: locationName),
          ),
        },
      ),
    );
  }
}
