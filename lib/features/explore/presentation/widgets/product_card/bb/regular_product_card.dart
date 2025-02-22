// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
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
  static const double _imageAspectRatio = 1.1;
  static const double _detailsHeight = 115.0;

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
      child: Padding(
        padding: EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: CardDecoration.standard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageSection(
                aspectRatio: _imageAspectRatio,
                imageUrl: model.images.firstOrNull,
                condition: model.condition,
                views: model.views,
                isOwner: model.isOwner,
                isViewed: model.isViewed,
              ),
              SizedBox(
                height: _detailsHeight,
                child: ProductDetailsSection(
                  title: model.title,
                  location: model.location,
                  price: model.price,
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
      ),
    );
  }
}

// Image section widget
class ProductImageSection extends StatelessWidget {
  final double aspectRatio;
  final String? imageUrl;
  final String condition;
  final int views;
  final bool isOwner;
  final bool isViewed;

  const ProductImageSection({
    super.key,
    required this.aspectRatio,
    required this.imageUrl,
    required this.condition,
    required this.views,
    required this.isOwner,
    required this.isViewed,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Stack(
          children: [
            _buildImage(),
            if (condition.isNotEmpty) _ConditionBadge(condition: condition),
            if (isViewed || isOwner)
              ViewsBadge(
                views: views,
                isOwner: isOwner,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: 'https://$imageUrl',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              memCacheWidth: 400,
              maxWidthDiskCache: 400,
              fadeInDuration: const Duration(milliseconds: 300),
              placeholder: _ImagePlaceholder.new,
              errorWidget: _ImageError.new,
              filterQuality: FilterQuality.low,
            )
          : const _DefaultImage(),
    );
  }
}

// Image placeholder widget
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(BuildContext context, String url);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
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
            'Image not found',
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
              'Logo not found',
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

// Condition badge widget
class _ConditionBadge extends StatelessWidget {
  final String condition;

  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          condition == "NEW_PRODUCT" ? 'New' : 'Used',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Views badge widget
class ViewsBadge extends StatelessWidget {
  final int views;
  final bool isOwner;

  const ViewsBadge({super.key, 
    required this.views,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              isOwner ? '$views' : 'Viewed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
    this.onLikeChanged, required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.productTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location,
          style: AppTextStyles.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Transform.translate(
          offset: const Offset(0, 6),
          child: const Text(
            'Price',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lightText,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatPrice(price.toString()),
              style: AppTextStyles.price,
            ),
            OptimizedLikeButton(
              productId: id,
              likes: likes,
              isOwner: isOwner,
              isLiked: isLiked,
              likeStatus: likeStatus,
            ),
          ],
        ),
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

// Owner Dialog Widget
class OwnerDialog extends StatelessWidget {
  const OwnerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DialogHeader(),
            const SizedBox(height: 16),
            const _DialogContent(),
            const SizedBox(height: 16),
            const _InfoBox(),
            const SizedBox(height: 20),
            const _DialogActions(),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "We're sorry, but you can't view your own publication details from this page yet.",
          style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          "Our development team is working on this feature! 👨‍💻",
          style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions();

  @override
  Widget build(BuildContext context) {
    return Row(
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
            shape: RoundedRectangleBorder(
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
    );
  }
}

// Constants and Styles
abstract class CardDecoration {
  static const standard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}

abstract class AppTextStyles {
  static const productTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const location = TextStyle(
    color: AppColors.lightText,
    fontSize: 13,
  );

  static const price = TextStyle(
    color: AppColors.primary,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
}


