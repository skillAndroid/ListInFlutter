// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';

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
        margin: EdgeInsets.all(1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSection(
              //  aspectRatio: _imageAspectRatio,
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
  final String? imageUrl;
  final String condition;
  final int likes;
  final bool isOwner;
  final bool isLiked;
  final String id;
  final LikeStatus likeStatus;

  // Aspect ratio constraints (width/height)
  final double minAspectRatio = 1.23; // 1:1 for square (minimum width = height)
  final double maxAspectRatio =
      0.7; // 3:4 for tall images (minimum height = 4/3 * width)

  const ProductImageSection({
    super.key,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatioMaintainer(
        imageUrl: imageUrl,
        minAspectRatio: minAspectRatio,
        maxAspectRatio: maxAspectRatio,
        builder: (context, childSize, child) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              child,
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
          );
        },
      ),
    );
  }
}

// Widget to load the image and maintain aspect ratio within constraints
class AspectRatioMaintainer extends StatefulWidget {
  final String? imageUrl;
  final double minAspectRatio;
  final double maxAspectRatio;
  final Widget Function(BuildContext context, Size childSize, Widget child)
      builder;

  const AspectRatioMaintainer({
    super.key,
    required this.imageUrl,
    required this.minAspectRatio,
    required this.maxAspectRatio,
    required this.builder,
  });

  @override
  State<AspectRatioMaintainer> createState() => _AspectRatioMaintainerState();
}

class _AspectRatioMaintainerState extends State<AspectRatioMaintainer> {
  Size _imageSize = Size.zero;
  bool _isLoading = true;
  late final ImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      _imageProvider = CachedNetworkImageProvider('https://${widget.imageUrl}');
      _loadImage();
    }
  }

  void _loadImage() {
    final ImageStream stream = _imageProvider.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            _imageSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
            _isLoading = false;
          });
        }
      },
      onError: (exception, stackTrace) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null) {
      return widget.builder(context, Size.zero, const _DefaultImage());
    }

    if (_isLoading) {
      return widget.builder(
        context,
        Size.zero,
        _ImagePlaceholder(context, '${widget.imageUrl}'),
      );
    }

    // Calculate constrained aspect ratio
    double aspectRatio = _imageSize.width / _imageSize.height;
    BoxFit imageFit = BoxFit.contain;

    // Determine if we need to crop the image to fill space
    if (aspectRatio > widget.minAspectRatio) {
      aspectRatio = widget.minAspectRatio; // Cap to minimum (1:1)
      imageFit = BoxFit.cover; // Use cover to crop and fill
    } else if (aspectRatio < widget.maxAspectRatio) {
      aspectRatio = widget.maxAspectRatio; // Cap to maximum (3:4)
      imageFit = BoxFit.cover; // Use cover to crop and fill
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: widget.builder(
        context,
        _imageSize,
        CachedNetworkImage(
          imageUrl: 'https://${widget.imageUrl}',
          fit: imageFit, // Now using the appropriate BoxFit
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: _ImagePlaceholder.new,
          errorWidget: _ImageError.new,
        ),
      ),
    );
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  maxLines: 1,
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: Constants.Arial,
          ),
        ), //
        // Text(
        //   location,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: TextStyle(
        //     color: Theme.of(context).colorScheme.surface,
        //     fontSize: 12,
        //     fontWeight: FontWeight.w300,
        //   ),
        // ),
        const SizedBox(height: 4),
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
      backgroundColor: Theme.of(context).cardColor,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 16,
          cornerSmoothing: 0.8,
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.not_available,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.view_in_profile,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cupertinoGreen,
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
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
