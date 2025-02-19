// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class DetailsUserProfilePublication extends StatefulWidget {
  final PublicationEntity product;
  final List<ProductEntity> recommendedProducts;

  const DetailsUserProfilePublication({
    super.key,
    required this.product,
    required this.recommendedProducts,
  });

  @override
  State<DetailsUserProfilePublication> createState() =>
      _ProfileProductDetailsScreenState();
}

class _ProfileProductDetailsScreenState
    extends State<DetailsUserProfilePublication> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        flexibleSpace: _buildTopBar(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageSlider(),
                      _buildMainContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 4,
        shadowColor: AppColors.blue.withOpacity(0.25),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 1,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<PublicationUpdateBloc>().add(
                          InitializePublication(
                              widget.product));
                      context.push(
                        Routes.publicationsEdit,
                        extra: widget.product,
                      );
                    },
                    icon: Icon(
                      color: AppColors.primary,
                      EvaIcons.edit,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show delete confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Publication'),
                          content: const Text(
                              'Are you sure you want to delete this publication?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Implement delete logic
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.delete_solid,
                      color: AppColors.error,
                      size: 22,
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

  Widget _buildImageSlider() {
    final hasVideo = widget.product.videoUrl != null;
    final totalItems = hasVideo
        ? widget.product.productImages.length + 1
        : widget.product.productImages.length;

    return Stack(
      children: [
        Container(
          color: AppColors.containerColor,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                // Show video thumbnail as first item if video exists
                if (hasVideo && index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: widget.product.videoUrl!,
                            thumbnailUrl:
                                'https://${widget.product.productImages[0].url}',
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://${widget.product.productImages[0].url}',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show regular images after video
                final imageIndex = hasVideo ? index - 1 : index;
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ProductImagesDetailed(
                    //       images: widget.product.productImages,
                    //       initialIndex: index, // Adjust index for video
                    //       heroTag: widget.product.id,
                    //       videoUrl: widget.product.videoUrl,
                    //     ),
                    //   ),
                    // );
                  },
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://${widget.product.productImages[imageIndex].url}',
                    fit: BoxFit
                        .cover, // Better than contain for most product images
                    filterQuality: FilterQuality
                        .high, // Balance between quality and performance
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.error_outline, color: Colors.red),
                    ),
                    cacheKey:
                        '${widget.product.id}_$imageIndex', // Unique cache key
                    useOldImageOnUrlChange:
                        true, // Show old image while loading new one
                    fadeOutDuration: const Duration(milliseconds: 100),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Text(
                  '${_currentPage + 1} - $totalItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Divider(
            color: AppColors.black,
            height: 2,
          ),
        )
      ],
    );
  }

  Widget _buildMainContent() {
    final enAttributes = widget.product.attributeValue.attributes['en'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrice(),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppIcons.favorite,
                          width: 22,
                          height: 22,
                          color: AppColors.darkGray,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          // widget.product.likes.toString(),
                          '3',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),
                  // Views counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.eye,
                          size: 24,
                          color: AppColors.darkGray,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          // widget.product.views.toString(),
                          '3',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        _buildTitle(),
        const SizedBox(height: 12),
        const SizedBox(height: 20),
        SizedBox(
          height: 4,
        ),
        if (enAttributes.isNotEmpty ||
            widget.product.attributeValue.numericValues.isNotEmpty)
        //  buildCharacteristics(enAttributes),
        SizedBox(
          height: 4,
        ),
        _buildDescription(),
        SizedBox(
          height: 16,
        ),
        _buildTrustAndSafety(),
        _buildBuyerProtection(),
        SizedBox(
          height: 20,
        ),
       
      ],
    );
  }

  Widget _buildPrice() {
    return Text(
      "${formatPrice(widget.product.price.toString())} Uz",
      style: const TextStyle(
        height: 1.2,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.description,
            maxLines: isMore == true ? 100 : 5,
            style: TextStyle(
              color: AppColors.darkBackground,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          TextButton(
            onPressed: () {
              if (isMore) {
                setState(() {
                  isMore = false;
                });
              } else {
                setState(() {
                  isMore = true;
                });
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isMore == true ? "Less" : 'More',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                  fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCharacteristics(Map<String, List<String>> enAttributes) {
    // Combine all features into a single list
    final List<MapEntry<String, String>> features = [];

    // Add regular attributes
    enAttributes.forEach((key, values) {
      if (values.isNotEmpty) {
        final value = values.length == 1 ? values[0] : values.join(', ');
        features.add(MapEntry(key, value));
      }
    });

    // Add numeric values
    for (var numericValue in widget.product.attributeValue.numericValues) {
      if (numericValue.numericValue.isNotEmpty) {
        features.add(
            MapEntry(numericValue.numericField, numericValue.numericValue));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Characteristics',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Show first 5 items
          ...features.take(5).map((feature) => _buildCharacteristicItem(
                feature.key,
                feature.value,
              )),
          // Show "See All" button if there are more items
          if (features.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: GestureDetector(
                onTap: () => _showAllCharacteristics(features),
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAllCharacteristics(List<MapEntry<String, String>> features) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 700, // Set fixed height (adjust as needed)
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Characteristics',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 600, // Fixed height for the list
              child: ListView(
                children: features
                    .map((feature) =>
                        _buildCharacteristicItem(feature.key, feature.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerProtection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Smaller height
          color: AppColors.containerColor,
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use verified payment methods and meet in safe locations to avoid scams.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustAndSafety() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.containerColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Safety',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Always check the item before buying. Avoid upfront payments without guarantees!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
}

class FullScreenMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const FullScreenMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          locationName,
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
      ),
      body: GoogleMap(
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: locationName),
          ),
        },
      ),
    );
  }
}
