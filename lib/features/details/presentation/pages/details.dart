// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GetPublicationEntity product;
  final List<ProductEntity> recommendedProducts;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.recommendedProducts,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isMore = false;

  bool _isBottomButtonVisible = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    bool shouldShowBottomButton = info.visibleFraction < 0.1;

    if (_isBottomButtonVisible != shouldShowBottomButton) {
      setState(() {
        _isBottomButtonVisible = shouldShowBottomButton;
      });
    }
  }

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
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        ),
        child:
            _isBottomButtonVisible ? _buildBottomButtons() : SizedBox.shrink(),
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
                  _buildTopBarButton(
                    icon: CupertinoIcons.doc_on_doc,
                    onTap: () {},
                  ),
                  _buildTopBarButton(
                    icon: CupertinoIcons.share,
                    onTap: () {},
                  ),
                  _buildTopBarButton(
                    icon: CupertinoIcons.ellipsis,
                    onTap: () {},
                  ),
                  _buildTopBarButton(
                    icon: CupertinoIcons.heart,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildButton(
                icon: EvaIcons.phoneCall,
                label: 'Call',
                color: AppColors.primary,
                textColor: Colors.white,
                onPressed: () {/* Call logic */},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildButton(
                icon: EvaIcons.messageSquare,
                label: 'Message',
                color: Colors.blue,
                textColor: AppColors.white,
                borderColor: AppColors.containerColor,
                onPressed: () {/* Message logic */},
              ),
            ),
          ],
        ),
        //
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: SmoothClipRRect(
        smoothness: 0.9,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: SmoothClipRRect(
              smoothness: 0.9,
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: borderColor ?? AppColors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductImagesDetailed(
                          images: widget.product.productImages,
                          initialIndex: index, // Adjust index for video
                          heroTag: widget.product.id,
                          videoUrl: widget.product.videoUrl,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://${widget.product.productImages[imageIndex].url}',
                    fit: BoxFit.contain,
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
                  color: Colors.black.withOpacity(0.7),
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
        _buildPrice(),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildShopInfo(),
        const SizedBox(height: 16),
        InkWell(
            onTap: () {
              context.push(Routes.anotherUserProfile, extra: {
                'userId': widget.product.seller.id,
              });
            },
            child: _buildLocation()),
        _buildSellerInfo(),
        _buildCalMessageButtons(),
        _buildLocationInfo(),
        if (enAttributes.isNotEmpty ||
            widget.product.attributeValue.numericValues.isNotEmpty)
          buildCharacteristics(enAttributes),
        _buildDescription(),
        _buildVerificationStatus(),
        _buildPriceEstimate(),
        SizedBox(
          height: 16,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Аватар продавца (25% ширины)

            // Информация о продавце (75% ширины)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      context.push(Routes.anotherUserProfile, extra: {
                        'userId': widget.product.seller.id,
                      });
                    },
                    child: _buildLocation(),
                  ),
                  _buildSellerInfo(),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Text(
                      "Subscribe",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[300], // Фон, если нет фото
                child: widget.product.seller.profileImagePath != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://${widget.product.seller.profileImagePath!}', // Исправил ошибку в URL
                          fit: BoxFit.cover,
                          width: 64, // Диаметр 2 * radius
                          height: 64,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error, color: Colors.red),
                        ),
                      )
                    : Icon(Icons.person, size: 32, color: Colors.white),
              ),
            ),
          ],
        ),
        _buildSimilarProducts(),
      ],
    );
  }

  Widget _buildSimilarProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Similar posts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 0.65,
          ),
          itemCount: widget.recommendedProducts.length,
          itemBuilder: (context, index) {
            return RegularProductCard(
              product: widget.recommendedProducts[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.seller.locationName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.blue,
                size: 19,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  children: [
                    const TextSpan(
                        text: "Working hours: ",
                        style: TextStyle(fontFamily: "Poppins")),
                    TextSpan(
                      text:
                          "${widget.product.seller.fromTime} - ${widget.product.seller.toTime}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.arrow_right_alt,
                color: Colors.blue,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                'Show in map',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo() {
    bool isBusinessSeller = widget.product.seller.role == "BUSINESS_SELLER";
    bool isBargain = widget.product.bargain;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: AppColors.containerColor,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    isBusinessSeller ? 'Store' : 'Individual',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isBusinessSeller ? Icons.store : Icons.person_4,
                    size: 24,
                    color: isBusinessSeller ? Colors.green : Colors.blue,
                  ),
                  if (isBargain) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Bargain',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.handshake, size: 20, color: Colors.orange),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        "${formatPrice(widget.product.price.toString())} Uz",
        style: const TextStyle(
          height: 1.1,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.seller.nickName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Created: ${DateFormat('dd MMMM yyyy').format(widget.product.seller.dateCreated)}',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                '5.0',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (widget.product.seller.rating != null) ...[
            RatingBarIndicator(
              rating: widget.product.seller.rating!,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 18,
            ),
          ],
          const SizedBox(width: 8),
          Text(
            '1 отзыв',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalMessageButtons() {
    return VisibilityDetector(
      key: Key('cal_message_visibility'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildButton(
                icon: EvaIcons.phoneCall,
                label: 'Call',
                color: AppColors.primary,
                textColor: Colors.white,
                onPressed: () {/* Call logic */},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildButton(
                icon: EvaIcons.messageSquare,
                label: 'Message',
                color: Colors.blue,
                textColor: Colors.white,
                borderColor: AppColors.containerColor,
                onPressed: () {/* Message logic */},
              ),
            ),
          ],
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
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.description,
            maxLines: isMore == true ? 100 : 5,
            style: TextStyle(
              color: AppColors.darkGray.withOpacity(0.6),
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
              fontSize: 28,
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
                fontSize: 28,
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

  Widget _buildVerificationStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Авто не проверено',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'На фото не виден госномер',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildPriceEstimate() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '4 200 000 ₽ — соответствует оценке Авито',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(flex: 3, child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



  // Widget _buildSelectedLocationCard(BuildContext context) {
  //   return SmoothClipRRect(
  //     borderRadius: BorderRadius.circular(16),
  //     child: Container(
  //       color: AppColors.white,
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(4.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SmoothClipRRect(
  //                   borderRadius: BorderRadius.circular(16),
  //                   child: SizedBox(
  //                     width: double.infinity,
  //                     height: 330,
  //                     child: Stack(
  //                       children: [
  //                         GoogleMap(
  //                           liteModeEnabled: true,
  //                           zoomControlsEnabled: false,
  //                           mapToolbarEnabled: true,
  //                           myLocationButtonEnabled: false,
  //                           compassEnabled: false,
  //                           initialCameraPosition: CameraPosition(
  //                             target: LatLng(
  //                               widget.product.latitude!,
  //                               widget.product.longitude!,
  //                             ),
  //                             zoom: 18,
  //                           ),
  //                           markers: {
  //                             Marker(
  //                               markerId: MarkerId('productLocation'),
  //                               position: LatLng(
  //                                 widget.product.latitude!,
  //                                 widget.product.longitude!,
  //                               ),
  //                             ),
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 // const SizedBox(height: 8),
  //                 // Transform.translate(
  //                 //   offset: Offset(0, 0),
  //                 //   child: Icon(
  //                 //     Ionicons.location,
  //                 //     color: AppColors.primary,
  //                 //     size: 18,
  //                 //   ),
  //                 // ),
  //                 // Padding(
  //                 //   padding: const EdgeInsets.symmetric(
  //                 //     vertical: 8,
  //                 //     horizontal: 4,
  //                 //   ),
  //                 //   child: Column(
  //                 //     crossAxisAlignment: CrossAxisAlignment.start,
  //                 //     children: [
  //                 //       SizedBox(
  //                 //         width: 150,
  //                 //         child: Text(
  //                 //           widget.product.locationName,
  //                 //           maxLines: 3,
  //                 //           overflow: TextOverflow.ellipsis,
  //                 //           style: const TextStyle(
  //                 //             color: AppColors.primary,
  //                 //             fontWeight: FontWeight.w600,
  //                 //           ),
  //                 //         ),
  //                 //       ),
  //                 //       const SizedBox(height: 8),
  //                 //       SmoothClipRRect(
  //                 //         borderRadius: BorderRadius.circular(10),
  //                 //         child: InkWell(
  //                 //           onTap: () {
  //                 //             MapDirectionsHandler.openDirections(
  //                 //               widget.product.latitude!,
  //                 //               widget.product.longitude!,
  //                 //             ).catchError((error) {
  //                 //               ScaffoldMessenger.of(context).showSnackBar(
  //                 //                 const SnackBar(
  //                 //                   content: Text(
  //                 //                     'Could not open maps. Please check if you have Google Maps installed or try again later.',
  //                 //                   ),
  //                 //                 ),
  //                 //               );
  //                 //             });
  //                 //           },
  //                 //           child: Container(
  //                 //             color: AppColors.containerColor,
  //                 //             margin: EdgeInsets.zero,
  //                 //             padding: EdgeInsets.zero,
  //                 //             child: const Padding(
  //                 //               padding: EdgeInsets.only(
  //                 //                   top: 4, bottom: 4, left: 8, right: 8),
  //                 //               child: Row(
  //                 //                 children: [
  //                 //                   Icon(
  //                 //                     CupertinoIcons.location_fill,
  //                 //                     size: 17,
  //                 //                   ),
  //                 //                   SizedBox(width: 4),
  //                 //                   Text(
  //                 //                     'Get Direction',
  //                 //                     style: TextStyle(
  //                 //                       color: AppColors.black,
  //                 //                       fontSize: 12,
  //                 //                       fontWeight: FontWeight.w600,
  //                 //                     ),
  //                 //                   ),
  //                 //                 ],
  //                 //               ),
  //                 //             ),
  //                 //           ),
  //                 //         ),
  //                 //       )
  //                 //     ],
  //                 //   ),
  //                 // )
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLocation() {
  //   return InkWell(
  //     onTap: () {
  //       print(
  //           '🌍 Latitude: ${widget.product.latitude} 🌐 Longitude: ${widget.product.longitude}');
  //       showModalBottomSheet(
  //         context: context,
  //         shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         constraints: BoxConstraints.tight(
  //             Size(double.infinity, 360)), // Set fixed height
  //         builder: (context) => SmoothClipRRect(
  //           borderRadius: BorderRadius.circular(16),
  //           child: Scaffold(
  //             backgroundColor: AppColors.white,
  //             body: Column(
  //               children: [
  //                 _buildSelectedLocationCard(context),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 CupertinoIcons
  //                     .location, // Using solid variant for better visibility
  //                 color: AppColors.black,
  //                 size: 20,
  //               ),
  //               const SizedBox(width: 10),
  //               SizedBox(
  //                 width: 250,
  //                 child: Text(
  //                   widget.product.seller.locationName,
  //                   style: const TextStyle(
  //                     fontSize: 15,
  //                     overflow: TextOverflow.ellipsis,
  //                     color: Color(0xFF2F2F2F),
  //                     fontWeight: FontWeight.w500,
  //                     height: 1.2,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Icon(
  //             CupertinoIcons.forward,
  //             color: Colors.grey.shade600,
  //             size: 24,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }