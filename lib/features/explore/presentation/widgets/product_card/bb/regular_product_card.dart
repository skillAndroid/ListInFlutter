// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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
      location: publication.seller.locationName,
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
  static const double _imageAspectRatio = 1;

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
        margin: EdgeInsets.all(1),
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
            padding: const EdgeInsets.all(3),
            child: SmoothClipRRect(
              smoothness: 0.8,
              borderRadius: BorderRadius.circular(20),
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
      color: Colors.grey[200],
      child: const Progress(),
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

// Details section widget
class ProductDetailsSection extends StatelessWidget {
  final String title;
  final String location;
  final String condition;
  final double price;
  final int likes;
  final String id;
  final bool isOwner;
  final bool isLiked;
  final LikeStatus likeStatus;
  final ValueChanged<bool>? onLikeChanged;

  const ProductDetailsSection({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.condition,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
    this.onLikeChanged,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatPrice(price.toString()),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.black,
          ),
        ),
        Text(
          condition == "NEW_PRODUCT"
              ? AppLocalizations.of(context)!.condition_new
              : AppLocalizations.of(context)!.condition_used,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.black,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.darkGray,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class ProductCardContainer extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductCardContainer({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GlobalBloc, GlobalState, ProductCardViewModel>(
      selector: (state) => ProductCardViewModel.fromPublication(product, state),
      builder: (context, model) {
        return OptimizedProductCard(
          model: model,
          onTap: () => _handleTap(context, model),
          onLikeChanged: (isLiked) =>
              _handleLikeChanged(context, model.id, isLiked),
        );
      },
    );
  }

  void _handleTap(BuildContext context, ProductCardViewModel model) {
    if (model.isOwner) {
      _showOwnerDialog(context);
    } else {
      context.push(Routes.productDetails, extra: product);
    }
  }

  void _handleLikeChanged(BuildContext context, String id, bool isLiked) {
    // Update local state immediately
    context.read<LikedPublicationsBloc>().add(
          UpdateLocalLikedPublication(
            publicationId: id,
            isLiked: isLiked,
          ),
        );

    // Update global state
    context.read<GlobalBloc>().add(
          UpdateLikeStatusEvent(
            publicationId: id,
            isLiked: isLiked,
            context: context,
          ),
        );
  }

  void _showOwnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const OwnerDialog(),
    );
  }
}

class OwnerDialog extends StatelessWidget {
  const OwnerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Cupertino active green color
    final Color cupertinoGreen = const Color(0xFF34C759);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.not_available,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.view_in_profile,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cupertinoGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(Routes.profile);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.profile,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
}

abstract class AppTextStyles {
  static const productTitle = TextStyle(
    fontSize: 14,
  );

  static const price = TextStyle(
    color: AppColors.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
