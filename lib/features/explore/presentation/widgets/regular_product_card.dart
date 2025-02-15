// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class HorizontalProfileProductCard extends StatelessWidget {
  final PublicationEntity product;
  const HorizontalProfileProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final String displayImage = product.productImages.isNotEmpty
        ? "https://${product.productImages[0].url}"
        : '';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      elevation: 0,
      shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(14), smoothness: 0.8),
      child: SizedBox(
        height: 115,
        child: Row(
          children: [
            SizedBox(
              child: Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    child: SmoothClipRRect(
                      smoothness: 0.8,
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        width: 100,
                        height: 110,
                        imageUrl: displayImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: SizedBox.shrink()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SmoothClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppColors.white.withOpacity(0.9),
                        child: Row(
                          children: [
                            Icon(Icons.remove_red_eye_rounded,
                                size: 13, color: AppColors.black),
                            SizedBox(width: 4),
                            Text(
                              '2.5k', // Keeping default value since view count isn't in entity
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SmoothClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.containerColor,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.bolt_fill,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'Boosted', // Keeping default value
                                      style: TextStyle(
                                        color: AppColors.darkGray,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: 14, color: AppColors.myRedBrown),
                            SizedBox(width: 4),
                            Text(
                              '1.2k', // Keeping default value since likes count isn't in entity
                              style: TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                context
                                    .read<PublicationUpdateBloc>()
                                    .add(InitializePublication(product));
                                context.push(
                                  Routes.publicationsEdit,
                                  extra: product,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.containerColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.darkGray,
                                  size: 18,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.containerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Ionicons.ellipsis_vertical,
                                color: AppColors.darkGray,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileProductCard extends StatelessWidget {
  final PublicationEntity product;
  const ProfileProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: CachedNetworkImage(
                      imageUrl: "https://${product.productImages[0].url}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: AppColors.white.withOpacity(0.9),
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded,
                            size: 14, color: AppColors.black),
                        SizedBox(width: 4),
                        Text(
                          '2.5k',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmoothClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor,
                    ),
                    child: Text(
                      'Boosted',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Product Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBackground,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$299.99',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            size: 16, color: AppColors.myRedBrown),
                        SizedBox(width: 4),
                        Text(
                          '1.2k',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: AppColors.darkGray,
                            size: 16,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Ionicons.ellipsis_vertical,
                            color: AppColors.darkGray,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegularProductCard extends StatelessWidget {
  final ProductEntity product;

  const RegularProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.productDetails.replaceAll(':id', product.id),
          //extra: getRecommendedProducts(product.id),
        );
      },
      child: Card(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with fixed aspect ratio
            AspectRatio(
              aspectRatio: 1.1, // Adjust this value to control image height
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Stack(
                  children: [
                    SmoothClipRRect(
                      smoothness: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox.expand(
                        child: CachedNetworkImage(
                          imageUrl: product.images[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SmoothCard(
                        margin: const EdgeInsets.all(0),
                        elevation: 0,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Content section with flexible height
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with flexible height
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2, // Allow multiple lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Location with single line
                    Text(
                      product.location,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    //  const SizedBox(height: 8),
                    // Price section with fixed height
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, 6),
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
                              '\$${product.price}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SmoothClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: AppColors.containerColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                      AppIcons.favorite,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemouteRegularProductCard extends StatelessWidget {
  final GetPublicationEntity product;

  const RemouteRegularProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.productDetails,
          extra: product, // Pass the entire product object directly
        );
      },
      child: Card(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with fixed aspect ratio
            AspectRatio(
              aspectRatio: 1.1, // Adjust this value to control image height
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Stack(
                  children: [
                    SmoothClipRRect(
                      smoothness: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: product.productImages.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    'https://${product.productImages[0].url}',
                                fit: BoxFit.cover,
                                memCacheWidth: 400,
                                maxWidthDiskCache: 400,
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      Colors.grey[200], // Light grey background
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Image.asset(
                                AppImages.appLogo,
                                fit: BoxFit.cover,
                                // Error handling for asset image
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
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
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SmoothCard(
                        margin: const EdgeInsets.all(0),
                        elevation: 0,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Content section with flexible height
            SizedBox(
              width: double.infinity,
              height: 115,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title with flexible height
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2, // Allow multiple lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.locationName,
                          style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Transform.translate(
                          offset: Offset(0, 6),
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
                              product.price.toString(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SmoothClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: AppColors.containerColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                      AppIcons.favorite,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemouteRegularProductCard2 extends StatelessWidget {
  final GetPublicationEntity product;

  const RemouteRegularProductCard2({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.productDetails,
          extra: product, // Pass the entire product object directly
        );
      },
      child: Card(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Stack(
                  children: [
                    SmoothClipRRect(
                      smoothness: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: product.productImages.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    'https://${product.productImages[0].url}',
                                fit: BoxFit.cover,
                                memCacheWidth: 400, // Limit memory cache width
                                maxWidthDiskCache:
                                    400, // Limit disk cache width
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: SizedBox.shrink()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                                filterQuality: FilterQuality
                                    .low, // Lower quality for better performance
                              )
                            : Image.asset(
                                AppImages.appLogo,
                                fit: BoxFit.cover,
                                // Error handling for asset image
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
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
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SmoothCard(
                        margin: const EdgeInsets.all(0),
                        elevation: 0,
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Content section with flexible height
            SizedBox(
              width: double.infinity,
              height: 115,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title with flexible height
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2, // Allow multiple lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.locationName,
                          style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Transform.translate(
                          offset: Offset(0, 6),
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
                              formatPrice(product.price.toString()),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SmoothClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: AppColors.containerColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.asset(
                                      AppIcons.favorite,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
