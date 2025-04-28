// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/owner_dialog.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

@immutable
class AdvertisedProductViewModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String condition;
  final List<String> images;
  final String? videoUrl;
  final int views;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final bool isViewed;
  final ViewStatus viewStatus;
  final LikeStatus likeStatus;
  final SellerInfo seller;

  const AdvertisedProductViewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.condition,
    required this.images,
    required this.videoUrl,
    required this.views,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.isViewed,
    required this.viewStatus,
    required this.likeStatus,
    required this.seller,
  });

  factory AdvertisedProductViewModel.fromPublication(
    GetPublicationEntity publication,
    GlobalState state,
  ) {
    return AdvertisedProductViewModel(
      id: publication.id,
      title: publication.title,
      description: publication.description,
      location: publication.locationName,
      price: publication.price,
      condition: publication.productCondition,
      images: publication.productImages.map((img) => img.url).toList(),
      videoUrl: publication.videoUrl,
      views: publication.views,
      likes: publication.likes,
      isOwner: AppSession.currentUserId == publication.seller.id,
      isLiked: state.isPublicationLiked(publication.id),
      isViewed: state.isPublicationViewed(publication.id),
      viewStatus: state.getViewStatus(publication.id),
      likeStatus: state.getLikeStatus(publication.id),
      seller: SellerInfo(
        id: publication.seller.id,
        name: publication.seller.nickName,
        imageUrl: publication.seller.profileImagePath,
        phoneNumber: publication.seller.phoneNumber,
        locationName: publication.locationName,
        rating: 4.5, // Hardcoded for now, should come from API
      ),
    );
  }
}

@immutable
class SellerInfo {
  final String id;
  final String name;
  final String? imageUrl;
  final String phoneNumber;
  final double rating;
  final String? locationName;

  const SellerInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phoneNumber,
    required this.rating,
    required this.locationName,
  });
}

class OptimizedAdvertisedCard extends StatelessWidget {
  final GetPublicationEntity product;
  final ValueNotifier<String?> currentlyPlayingId;

  const OptimizedAdvertisedCard({
    super.key,
    required this.product,
    required this.currentlyPlayingId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GlobalBloc, GlobalState, AdvertisedProductViewModel>(
      selector: (state) =>
          AdvertisedProductViewModel.fromPublication(product, state),
      builder: (context, model) {
        return _OptimizedCardContent(
          model: model,
          currentlyPlayingId: currentlyPlayingId,
          product: product,
        );
      },
    );
  }
}

class _OptimizedCardContent extends StatefulWidget {
  final AdvertisedProductViewModel model;
  final ValueNotifier<String?> currentlyPlayingId;
  final GetPublicationEntity product;

  const _OptimizedCardContent({
    required this.model,
    required this.currentlyPlayingId,
    required this.product,
  });

  @override
  _OptimizedCardContentState createState() => _OptimizedCardContentState();
}

class _OptimizedCardContentState extends State<_OptimizedCardContent> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(BuildContext context) async {
    final cleanPhoneNumber =
        widget.model.seller.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uriString = 'tel:$cleanPhoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(uriString))) {
        await launchUrl(Uri.parse(uriString));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error: Unable to launch call to $cleanPhoneNumber")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  void _handleCardTap() {
    if (!widget.model.isOwner) {
      context.push(Routes.productDetails, extra: widget.product);
    } else {
      _showOwnerDialog(context);
    }
  }

  void _showOwnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const OwnerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCardTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info section at top
          //    _UserInfoHeader(seller: widget.model.seller),

          // Media carousel
          _buildMediaCarousel(),

          // Product info section
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description in same line as rich text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.model.title} ",
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            fontFamily: Constants.Arial,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 4),

                // Price and action buttons
                Row(
                  children: [
                    SizedBox(
                      width: 4,
                    ),
                    // Price
                    Text(
                      formatPrice(widget.model.price.toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const Spacer(),

                    // Call button
                    _ActionButton(
                      color: Colors.green,
                      onPressed: !widget.model.isOwner
                          ? () => _makeCall(context)
                          : null,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.5),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.model.images.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => _MediaContent(
                  imageUrl: widget.model.images[index],
                  videoUrl: index == 0 ? widget.model.videoUrl : null,
                  isPlaying: widget.currentlyPlayingId.value == widget.model.id,
                  productId: widget.model.id,
                ),
              ),
              if (!widget.model.isOwner)
                OptimizedLikeButton(
                  productId: widget.model.id,
                  likes: widget.model.likes,
                  isOwner: widget.model.isOwner,
                  isLiked: widget.model.isLiked,
                  likeStatus: widget.model.likeStatus,
                ),
              // Page indicator in top right of image
              Positioned(
                top: 10,
                right: 14,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1} of ${widget.model.images.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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

class _UserInfoHeader extends StatelessWidget {
  final SellerInfo seller;

  const _UserInfoHeader({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 14,
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            child: seller.imageUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: 'https://${seller.imageUrl}',
                      fit: BoxFit.cover,
                      width: 26, // 2 * radius
                      height: 26, // 2 * radius
                      memCacheWidth:
                          150, // Low resolution for performance (2x for high DPI)
                      httpHeaders: const {
                        'Accept': 'image/webp,image/jpeg'
                      }, // Prefer optimized formats
                      placeholder: (context, url) => const Icon(Icons.person,
                          color: Colors.white70, size: 20),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20),
                      fadeInDuration: const Duration(milliseconds: 150),
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),

          Text(
            seller.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: 24, // Control the overall width
      height: 24, // Control the overall height
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero, // Remove padding
        constraints: BoxConstraints(), // Remove default constraints
        style: IconButton.styleFrom(
          foregroundColor: isDisabled ? Colors.grey : color,
          backgroundColor:
              isDisabled ? Colors.grey[100] : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          minimumSize: const Size(28, 28), // Set minimum size
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target
        ),
        icon: const Icon(CupertinoIcons.phone_fill,
            size: 16), // Smaller icon size
      ),
    );
  }
}

class OptimizedLikeButton extends StatefulWidget {
  final String productId;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final LikeStatus likeStatus;
  final double size;
  final double bootom;
  final double right;

  const OptimizedLikeButton({
    super.key,
    required this.productId,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
    this.size = 32,
    this.bootom = 8,
    this.right = 8,
  });

  @override
  State<OptimizedLikeButton> createState() => _OptimizedLikeButtonState();
}

class _OptimizedLikeButtonState extends State<OptimizedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateLike() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOwner) {
      return SizedBox();
    }

    final isLoading = widget.likeStatus == LikeStatus.inProgress;

    return Positioned(
      bottom: widget.bootom,
      right: widget.right,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                _animateLike();
                context.read<GlobalBloc>().add(
                      UpdateLikeStatusEvent(
                        publicationId: widget.productId,
                        isLiked: widget.isLiked,
                        context: context,
                      ),
                    );
              },
        child: isLoading
            ? ShimmerEffect(
                isLiked: widget.isLiked,
                child: _buildLikeIcon(),
              )
            : ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLikeIcon(),
              ),
      ),
    );
  }

  Widget _buildLikeIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: widget.size,
      height: widget.size,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          widget.isLiked ? AppIcons.favoriteBlack : AppIcons.favorite,
          color: widget.isLiked
              ? Colors.red
              : Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  final String imageUrl;
  final String? videoUrl;
  final bool isPlaying;
  final String productId;

  const _MediaContent({
    required this.imageUrl,
    required this.videoUrl,
    required this.isPlaying,
    required this.productId,
  });

  String _getFormattedUrl(String url) => 'https://$url';

  @override
  Widget build(BuildContext context) {
    if (videoUrl != null && isPlaying) {
      return Container(
        color: AppColors.black,
        child: SimpleVideoPlayerWidget(
          key: ValueKey('video_$productId'),
          videoUrl: _getFormattedUrl(videoUrl!),
          thumbnailUrl: _getFormattedUrl(imageUrl),
        ),
      );
    }

    return CachedNetworkImage(
      key: ValueKey('image_$productId'),
      imageUrl: _getFormattedUrl(imageUrl),
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => Container(
        color: Theme.of(context).cardColor,
        child: const Progress(),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).cardColor,
        child: const Center(child: Icon(Icons.error)),
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final bool isLiked;

  const ShimmerEffect({
    super.key,
    required this.child,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isLiked ? Colors.grey[300]! : Colors.grey[400]!,
      highlightColor: isLiked ? Colors.grey[100]! : Colors.grey[200]!,
      child: child,
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${currentPage + 1} of $totalPages',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
