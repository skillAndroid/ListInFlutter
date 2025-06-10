// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/product_details_section.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';

// Core entity model
@immutable
class ProductCardViewModel {
  final String id;
  final String title;
  final String location;
  final double price;
  final String condition;
  final List<String> images;
  final int views;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final bool isViewed;
  final ViewStatus viewStatus;
  final LikeStatus likeStatus;

  const ProductCardViewModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.condition,
    required this.images,
    required this.views,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.isViewed,
    required this.viewStatus,
    required this.likeStatus,
  });

  factory ProductCardViewModel.fromPublication(
    GetPublicationEntity publication,
    GlobalState state,
  ) {
    return ProductCardViewModel(
      id: publication.id,
      title: publication.title,
      location: publication.locationName,
      price: publication.price,
      condition: publication.productCondition,
      images: publication.productImages.map((img) => img.url).toList(),
      views: publication.views,
      likes: publication.likes,
      isOwner: AppSession.currentUserId == publication.seller.id,
      isLiked: state.isPublicationLiked(publication.id),
      isViewed: state.isPublicationViewed(publication.id),
      viewStatus: state.getViewStatus(publication.id),
      likeStatus: state.getLikeStatus(publication.id),
    );
  }
}

// Main product card widget
class OptimizedProductCard extends StatelessWidget {
  static const double _imageAspectRatio = 0.8;

  final ProductCardViewModel model;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onLikeChanged;

  const OptimizedProductCard({
    super.key,
    required this.model,
    this.onTap,
    this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSection(
              aspectRatio: _imageAspectRatio,
              imageUrl: model.images.firstOrNull,
              condition: model.condition,
              likes: model.likes,
              isOwner: model.isOwner,
              isLiked: model.isLiked,
              id: model.id,
              likeStatus: model.likeStatus,
            ),
            SizedBox(
              child: ProductDetailsSection(
                title: model.title,
                location: model.location,
                price: model.price,
                condition: model.condition,
                likes: model.likes,
                isOwner: model.isOwner,
                isLiked: model.isLiked,
                id: model.id,
                likeStatus: model.likeStatus,
                onLikeChanged: onLikeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductImageSection extends StatelessWidget {
  final double aspectRatio;
  final String? imageUrl;
  final String condition;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final String id;
  final LikeStatus likeStatus;

  const ProductImageSection({
    super.key,
    required this.aspectRatio,
    required this.imageUrl,
    required this.condition,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.id,
    required this.likeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: ClipSmoothRect(
              radius:
                  SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.8),
              //  borderRadius: BorderRadius.circular(18),
              child: _buildImage(),
            ),
          ),
          if (!isOwner)
            Positioned(
              bottom: 8,
              right: 8,
              child: OptimizedLikeButton(
                productId: id,
                likes: likes,
                isOwner: isOwner,
                isLiked: isLiked,
                likeStatus: likeStatus,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return imageUrl != null
        ? CachedNetworkImage(
            imageUrl: 'https://$imageUrl',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fadeInDuration: const Duration(milliseconds: 300),
            placeholder: _ImagePlaceholder.new,
            errorWidget: _ImageError.new,
            filterQuality: FilterQuality.medium,
          )
        : const _DefaultImage();
  }
}

// Image placeholder widget
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(BuildContext context, String url);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
    );
  }
}

// Image error widget
class _ImageError extends StatelessWidget {
  const _ImageError(BuildContext context, String url, dynamic error);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.grey[400], size: 32),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.image_not_found,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Default image widget
class _DefaultImage extends StatelessWidget {
  const _DefaultImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.appLogo,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.logo_not_found,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
