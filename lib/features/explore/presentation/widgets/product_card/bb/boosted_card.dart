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
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  const SellerInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phoneNumber,
    required this.rating,
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
      child: Card(
        shadowColor: Colors.black.withOpacity(0.25),
        color: AppColors.white,
        elevation: 4,
        margin: EdgeInsets.all(3),
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMediaCarousel(),
            _ProductInfo(
              model: widget.model,
              onCallPressed: () => _makeCall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return Padding(
      padding: EdgeInsets.all(3),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 11,
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
              PageIndicator(
                currentPage: _currentPage,
                totalPages: widget.model.images.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final AdvertisedProductViewModel model;
  final VoidCallback onCallPressed;

  const _ProductInfo({
    required this.model,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  model.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Price with condition tag
          Text(
            formatPrice(model.price.toString()),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.black,
            ),
          ),
          Text(
            model.condition == "NEW_PRODUCT" ?  AppLocalizations.of(context)!.condition_new :  AppLocalizations.of(context)!.condition_used,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.black,
              fontWeight: FontWeight.w300,
            ),
          ),

          _SellerInfo(model: model),
          Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            model.description,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 13.5,
            ),
          ),
          Text(
            model.location,
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),

          // Call button
          _CallButton(
            isOwner: model.isOwner,
            onPressed: onCallPressed,
          ),
        ],
      ),
    );
  }
}

class _SellerInfo extends StatelessWidget {
  final AdvertisedProductViewModel model;

  const _SellerInfo({required this.model});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          model.seller.name,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13.5,
            color: AppColors.black,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        const Icon(
          CupertinoIcons.star_fill,
          color: CupertinoColors.systemYellow,
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          model.seller.rating.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${model.views})',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.darkGray.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class OptimizedLikeButton extends StatefulWidget {
  final String productId;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final LikeStatus likeStatus;

  const OptimizedLikeButton({
    super.key,
    required this.productId,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
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
      bottom: 8,
      right: 8,
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: AppColors.white.withOpacity(0.75),
            ),
            width: 32,
            height: 32,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                widget.isLiked ? AppIcons.favoriteBlack : AppIcons.favorite,
                color: widget.isLiked ? Colors.red : AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final bool isOwner;
  final VoidCallback onPressed;

  const _CallButton({
    required this.isOwner,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isOwner ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(32),
        padding: const EdgeInsets.symmetric(vertical: 0),
        backgroundColor: isOwner ? Colors.grey.shade200 : Colors.white,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(width: 1, color: AppColors.primary)),
        elevation: 0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            isOwner ? AppLocalizations.of(context)!.cant_call_own_number : AppLocalizations.of(context)!.call,
            style: TextStyle(
              fontSize: 14,
              fontFamily: Constants.Arial,
              fontWeight: FontWeight.w600,
              color: isOwner ? Colors.grey.shade600 : AppColors.primary,
            ),
          ),
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
        child: VideoPlayerWidget(
          key: ValueKey('video_$productId'),
          videoUrl: _getFormattedUrl(videoUrl!),
          thumbnailUrl: _getFormattedUrl(imageUrl),
          isPlaying: true,
          onPlay: () {},
          onPause: () {},
        ),
      );
    }

    return CachedNetworkImage(
      key: ValueKey('image_$productId'),
      imageUrl: _getFormattedUrl(imageUrl),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Progress(),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.error)),
      ),
      filterQuality: FilterQuality.low,
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
