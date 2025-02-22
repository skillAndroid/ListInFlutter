// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
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
      _showOwnerDialog();
    }
  }

  void _showOwnerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: SmoothRectangleBorder(
          smoothness: 0.7,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Under Construction',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('🚧', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "We're sorry, but you can't view your own publication details from this page yet.",
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Our development team is working on this feature! 👨‍💻",
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✨', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'To view or edit your publication, please go to your profile.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('✨', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(Routes.profile);
                    },
                    child: const Text(
                      'Go to Profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK, Got it',
                      style: TextStyle(fontFamily: 'Poppins'),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCardTap,
      child: Card(
        shadowColor: AppColors.black.withOpacity(0.5),
        color: AppColors.white,
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 4,
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
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 10.5,
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
            if (widget.model.condition.isNotEmpty)
              _ConditionBadge(condition: widget.model.condition),
            if(widget.model.isViewed || widget.model.isOwner)  
            ViewsBadge(
                views: widget.model.views,
                isOwner: widget.model.isOwner,
              ),
            PageIndicator(
              currentPage: _currentPage,
              totalPages: widget.model.images.length,
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _SellerInfo(model: model),
          const SizedBox(height: 6),
          Text(
            model.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            model.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGray.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.location,
                    style: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrice(model.price.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              OptimizedLikeButton(
                productId: model.id,
                likes: model.likes,
                isOwner: model.isOwner,
                isLiked: model.isLiked,
                likeStatus: model.likeStatus,
              ),
            ],
          ),
          const SizedBox(height: 2),
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
      children: [
        _SellerAvatar(imageUrl: model.seller.imageUrl),
        const SizedBox(width: 8),
        Text(
          model.seller.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          CupertinoIcons.star_fill,
          color: CupertinoColors.systemYellow,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          model.seller.rating.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class OptimizedLikeButton extends StatelessWidget {
  final String productId;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final LikeStatus likeStatus;

  const OptimizedLikeButton({super.key, 
    required this.productId,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return _buildOwnerLikeButton();
    }

    final isLoading = likeStatus == LikeStatus.inProgress;

    return InkWell(
      onTap: isLoading
          ? null
          : () => context.read<GlobalBloc>().add(
                UpdateLikeStatusEvent(
                  publicationId: productId,
                  isLiked: isLiked,
                  context: context,
                ),
              ),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: isLiked ? AppColors.primary : AppColors.containerColor,
          child: isLoading
              ? ShimmerEffect(
                  isLiked: isLiked,
                  child: _buildLikeIcon(),
                )
              : _buildLikeIcon(),
        ),
      ),
    );
  }

  Widget _buildOwnerLikeButton() {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: AppColors.containerColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Image.asset(
                  AppIcons.favorite,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikeIcon() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 18,
        height: 18,
        child: Image.asset(
          AppIcons.favorite,
          color: isLiked ? Colors.white : AppColors.darkGray,
        ),
      ),
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  final String condition;

  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const BoxDecoration(
            color: AppColors.white,
          ),
          child: Text(
            condition == "NEW_PRODUCT" ? 'New' : "Used",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
        backgroundColor: isOwner ? Colors.grey.shade200 : AppColors.primary,
        shape: SmoothRectangleBorder(
          smoothness: 1,
          side: BorderSide(
            width: 1.2,
            color: isOwner ? Colors.grey.shade400 : AppColors.primary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            isOwner ? "You can't call your own number" : 'Call Now',
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              color: isOwner ? Colors.grey.shade600 : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String? imageUrl;

  const _SellerAvatar({required this.imageUrl});

  String _getFormattedUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : CachedNetworkImage(
                imageUrl: _getFormattedUrl(imageUrl),
                fit: BoxFit.cover,
                memCacheWidth: 120,
                maxWidthDiskCache: 120,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 16),
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

  String _getFormattedUrl(String url) =>
      url.startsWith('http') ? url : 'https://$url';

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
      memCacheWidth: 700,
      maxWidthDiskCache: 700,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
      bottom: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${currentPage + 1}/$totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
