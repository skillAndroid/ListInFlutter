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
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:url_launcher/url_launcher.dart';


class AdvertisedProductCard extends StatefulWidget {
  final GetPublicationEntity product;
  final ValueNotifier<String?> currentlyPlayingId;

  const AdvertisedProductCard({
    super.key,
    required this.product,
    required this.currentlyPlayingId,
  });

  @override
  _AdvertisedProductCardState createState() => _AdvertisedProductCardState();
}

class _AdvertisedProductCardState extends State<AdvertisedProductCard> {
  late PageController _pageController;
  int _currentPage = 0;
  // Check owner status once at initialization
  late final bool _isOwner;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isOwner = AppSession.currentUserId == widget.product.seller.id;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.push(
            Routes.productDetails,
            extra: widget.product,
          );
        },
        child: Card(
          shadowColor: AppColors.black.withOpacity(0.2),
          color: AppColors.white,
          shape: SmoothRectangleBorder(
            smoothness: 0.8,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          clipBehavior: Clip.hardEdge,
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImageCarousel(),
              ProductDetails(
                product: widget.product,
                isOwner: _isOwner,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageCarousel() {
    return AspectRatio(
      aspectRatio: 16 / 10.5,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.currentlyPlayingId,
        builder: (context, currentlyPlayingId, _) {
          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.product.productImages.length,
                onPageChanged: (page) => setState(() {
                  _currentPage = page;
                }),
                itemBuilder: (context, index) => ProductMediaContent(
                  product: widget.product,
                  index: index,
                  currentPage: _currentPage,
                  isPlaying: currentlyPlayingId == widget.product.id,
                ),
              ),
              _NewBadge(condition: widget.product.productCondition),
              _ViewedStatusBadge(
                productId: widget.product.id,
                views: widget.product.views,
                isOwner: _isOwner,
              ),
              PageIndicator(
                currentPage: _currentPage,
                totalPages: widget.product.productImages.length,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NewBadge extends StatefulWidget {
  final String condition;
  
  const _NewBadge({
    required this.condition,
  });

  @override
  State<_NewBadge> createState() => _NewBadgeState();
}

class _NewBadgeState extends State<_NewBadge> {
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
            widget.condition == "NEW_PRODUCT" ? 'New' : "Used",
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

class _ViewedStatusBadge extends StatelessWidget {
  final String productId;
  final int views;
  final bool isOwner;

  const _ViewedStatusBadge({
    required this.productId,
    required this.views,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (previous, current) {
        // Only rebuild when view status changes for this specific product
        final previousViewed = previous.isPublicationViewed(productId);
        final currentViewed = current.isPublicationViewed(productId);
        final previousStatus = previous.getViewStatus(productId);
        final currentStatus = current.getViewStatus(productId);
        
        return previousViewed != currentViewed || previousStatus != currentStatus;
      },
      builder: (context, state) {
        final isViewed = state.isPublicationViewed(productId);
        final viewStatus = state.getViewStatus(productId);
        
        if (isViewed || viewStatus == ViewStatus.inProgress || isOwner) {
          return Positioned(
            top: 8,
            right: 8,
            child: SmoothCard(
              margin: const EdgeInsets.all(0),
              elevation: 0,
              color: AppColors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility,
                      color: AppColors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwner ? '$views' : 'Viewed',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
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

class ProductDetails extends StatelessWidget {
  final GetPublicationEntity product;
  final bool isOwner;

  const ProductDetails({
    super.key,
    required this.product,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _SellerInfo(seller: product.seller),
          const SizedBox(height: 6),
          _ProductTitle(title: product.title),
          _ProductDescription(description: product.description),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LocationInfo(location: product.locationName),
                  const SizedBox(height: 2),
                  _PriceSection(price: product.price),
                ],
              ),
              _LikeButton(
                productId: product.id,
                likes: product.likes,
                isOwner: isOwner,
              ),
            ],
          ),
          const SizedBox(height: 2),
          _CallButton(
            phoneNumber: product.seller.phoneNumber,
            isOwner: isOwner,
          ),
        ],
      ),
    );
  }
}

class _ProductTitle extends StatelessWidget {
  final String title;

  const _ProductTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SellerInfo extends StatelessWidget {
  final SellerEntity seller;

  const _SellerInfo({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SellerAvatar(imageUrl: seller.profileImagePath),
        const SizedBox(width: 8),
        Text(
          seller.nickName,
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
        const Text(
          "4.5",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
class _SellerAvatar extends StatelessWidget {
  final String? imageUrl;

  const _SellerAvatar({required this.imageUrl});

  String _getFormattedUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // Check if URL already starts with http/https
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final String location;

  const _LocationInfo({required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          location,
          style: TextStyle(
            color: AppColors.darkGray.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ProductDescription extends StatelessWidget {
  final String description;

  const _ProductDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.darkGray.withOpacity(0.7),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _PriceSection extends StatelessWidget {
  final double price;

  const _PriceSection({required this.price});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPrice(
        price.toString(),
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: AppColors.primary,
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final String productId;
  final int likes;
  final bool isOwner;

  const _LikeButton({
    required this.productId,
    required this.likes,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return _buildOwnerLikeButton();
    }
    
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (previous, current) {
        // Only rebuild when like status changes for this specific product
        final previousLiked = previous.isPublicationLiked(productId);
        final currentLiked = current.isPublicationLiked(productId);
        final previousStatus = previous.getLikeStatus(productId);
        final currentStatus = current.getLikeStatus(productId);
        
        return previousLiked != currentLiked || previousStatus != currentStatus;
      },
      builder: (context, state) {
        final isLiked = state.isPublicationLiked(productId);
        final likeStatus = state.getLikeStatus(productId);
        final isLoading = likeStatus == LikeStatus.inProgress;

        return InkWell(
          onTap: () {
            if (!isLoading) {
              context.read<GlobalBloc>().add(
                UpdateLikeStatusEvent(
                  publicationId: productId,
                  isLiked: isLiked,
                  context: context,
                ),
              );
            }
          },
          child: SmoothClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: isLiked
                  ? AppColors.primary
                  : AppColors.containerColor,
              child: isLoading
                  ? ShimmerEffect(
                      isLiked: isLiked,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Image.asset(
                            AppIcons.favorite,
                            color: isLiked
                                ? Colors.white
                                : AppColors.darkGray,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: Image.asset(
                          AppIcons.favorite,
                          color: isLiked
                              ? Colors.white
                              : AppColors.darkGray,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
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
}

class _CallButton extends StatelessWidget {
  final String phoneNumber;
  final bool isOwner;

  const _CallButton({
    required this.phoneNumber,
    required this.isOwner,
  });

  Future<void> _makeCall(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isOwner ? null : () => _makeCall(context),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isOwner ? Colors.grey.shade200 : AppColors.white,
        shape: SmoothRectangleBorder(
          smoothness: 1,
          side: BorderSide(
            width: 1.2,
            color: isOwner ? Colors.grey.shade400 : AppColors.primary,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
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
              color: isOwner ? Colors.grey.shade600 : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductMediaContent extends StatelessWidget {
  final GetPublicationEntity product;
  final int index;
  final int currentPage;
  final bool isPlaying;

  const ProductMediaContent({
    super.key,
    required this.product,
    required this.index,
    required this.currentPage,
    required this.isPlaying,
  });

  String _getFormattedUrl(String url) => 'https://$url';

  @override
  Widget build(BuildContext context) {
    if (index == 0 && product.videoUrl != null && isPlaying) {
      return VideoPlayerWidget(
        key: ValueKey('video_${product.id}'),
        videoUrl: _getFormattedUrl(product.videoUrl!),
        thumbnailUrl: _getFormattedUrl(product.productImages[0].url),
        isPlaying: true,
        onPlay: () {},
        onPause: () {},
      );
    }

    // Show image for all other cases
    return CachedNetworkImage(
      key: ValueKey('image_${product.id}_$index'),
      imageUrl: _getFormattedUrl(product.productImages[index].url),
      fit: BoxFit.cover,
      memCacheWidth: 700,
      maxWidthDiskCache: 700,
      placeholder: (context, url) => const Progress(),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error),
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