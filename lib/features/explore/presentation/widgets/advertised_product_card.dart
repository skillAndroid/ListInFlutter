// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AdvertisedProductCard extends StatelessWidget {
  final GetPublicationEntity product;
  final ValueNotifier<String?> currentlyPlayingId;
  final ValueNotifier<int> pageNotifier;

  const AdvertisedProductCard({
    super.key,
    required this.product,
    required this.currentlyPlayingId,
    required this.pageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shadowColor: AppColors.black.withOpacity(0.2),
        color: AppColors.white,
        shape: SmoothRectangleBorder(
          smoothness: 0.8,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageCarousel(
              product: product,
              currentlyPlayingId: currentlyPlayingId,
              pageNotifier: pageNotifier,
            ),
            ProductDetails(product: product),
          ],
        ),
      ),
    );
  }
}

class ProductImageCarousel extends StatelessWidget {
  final GetPublicationEntity product;
  final ValueNotifier<String?> currentlyPlayingId;
  final ValueNotifier<int> pageNotifier;

  const ProductImageCarousel({
    super.key,
    required this.product,
    required this.currentlyPlayingId,
    required this.pageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 11,
      child: ValueListenableBuilder<String?>(
        valueListenable: currentlyPlayingId,
        builder: (context, currentlyPlayingId, _) {
          return ValueListenableBuilder<int>(
            valueListenable: pageNotifier,
            builder: (context, currentPage, _) {
              return Stack(
                children: [
                  PageView.builder(
                    itemCount: product.productImages.length,
                    onPageChanged: (page) => pageNotifier.value = page,
                    itemBuilder: (context, index) => ProductMediaContent(
                      product: product,
                      index: index,
                      currentPage: currentPage,
                      isPlaying: currentlyPlayingId == product.id,
                    ),
                  ),
                  const _NewBadge(),
                  PageIndicator(
                    currentPage: currentPage,
                    totalPages: product.productImages.length,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 8,
      left: 8,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        color: AppColors.primary,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            'New',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
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
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductTitle(title: product.title),
          const SizedBox(height: 8),
          _SellerInfo(seller: product.seller),
          const SizedBox(height: 8),
          _LocationInfo(location: product.locationName),
          const SizedBox(height: 8),
          _ProductDescription(description: product.description),
          const SizedBox(height: 8),
          _PriceSection(price: product.price),
          const SizedBox(height: 4),
          const _CallButton(),
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
        fontWeight: FontWeight.w600,
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
            color: AppColors.green,
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
            color: AppColors.green,
          ),
        ),
      ],
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String? imageUrl;

  const _SellerAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CachedNetworkImage(
          imageUrl: "https://$imageUrl",
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error)),
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
        const Icon(
          Ionicons.location,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
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
        fontSize: 12,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              price.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.primary,
              ),
            ),
            const _FavoriteButton(),
          ],
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 18,
        height: 18,
        child: Image.asset(
          AppIcons.favorite,
          color: AppColors.darkGray,
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            'Call Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
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
      placeholder: (context, url) => const _LoadingIndicator(),
      errorWidget: (context, url, error) => const _ErrorWidget(),
    );
  }
}

// Extracted widgets for better reusability and const optimization
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.white,
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.error),
    );
  }
}
