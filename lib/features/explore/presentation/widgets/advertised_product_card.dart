// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
              ProductDetails(product: widget.product),
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
              const _NewBadge(),
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

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
          child: Text(
            'New',
            style: TextStyle(
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${currentPage + 1}/$totalPages',
            style: TextStyle(
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
          const SizedBox(height: 4),
          _SellerInfo(seller: product.seller),
          const SizedBox(height: 6),
          _ProductTitle(title: product.title),
          ProductDescription(description: product.description),
          const SizedBox(height: 6),
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
              Container(
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Image.asset(
                    AppIcons.favorite,
                    color: AppColors.darkGray,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 2),
          const CallButton(),
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
        Text(
          location,
          style: TextStyle(
            color: AppColors.darkGray.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class ProductDescription extends StatelessWidget {
  final String description;

  const ProductDescription({super.key, required this.description});

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

class CallButton extends StatelessWidget {
  const CallButton({super.key});

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
              fontSize: 14,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
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
    return Progress();
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
