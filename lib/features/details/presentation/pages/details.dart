// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/details/presentation/pages/product_images_detailed.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/map/presentation/widgets/map_direction_handler.dart';
import 'package:list_in/main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GetPublicationEntity product;
  final List<ProductEntity> recommendedProducts;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.recommendedProducts,
  });

  @override
  State<ProductDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool isMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 300 && !_isCollapsed) {
      setState(() => _isCollapsed = true);
    } else if (_scrollController.offset <= 300 && _isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  Widget _buildFeatureChip(String text) {
    return SmoothClipRRect(
      side: BorderSide(width: 1, color: AppColors.containerColor),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: AppColors.white,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: AppColors.darkGray,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBody() {
    final enAttributes = widget.product.attributeValue.attributes['en'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildProductTitle(),
        if (enAttributes.isNotEmpty) _buildFeatures(enAttributes),
        _buildDivider(),
        _buildSellerInfo(),
        _buildDivider(),
        _buildDescription(),
        _buildDivider(),
        _buildLocation(),
        _buildDivider(),
        _buildReviews(),
        _buildDivider(),
        _buildSimilarProducts(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSimilarProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Similar posts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
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

  Widget _buildSelectedLocationCard(BuildContext context) {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmoothClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 330,
                      child: Stack(
                        children: [
                          GoogleMap(
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: true,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.product.latitude!,
                                widget.product.longitude!,
                              ),
                              zoom: 18,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('productLocation'),
                                position: LatLng(
                                  widget.product.latitude!,
                                  widget.product.longitude!,
                                ),
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Transform.translate(
                  //   offset: Offset(0, 0),
                  //   child: Icon(
                  //     Ionicons.location,
                  //     color: AppColors.primary,
                  //     size: 18,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     vertical: 8,
                  //     horizontal: 4,
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       SizedBox(
                  //         width: 150,
                  //         child: Text(
                  //           widget.product.locationName,
                  //           maxLines: 3,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: const TextStyle(
                  //             color: AppColors.primary,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       SmoothClipRRect(
                  //         borderRadius: BorderRadius.circular(10),
                  //         child: InkWell(
                  //           onTap: () {
                  //             MapDirectionsHandler.openDirections(
                  //               widget.product.latitude!,
                  //               widget.product.longitude!,
                  //             ).catchError((error) {
                  //               ScaffoldMessenger.of(context).showSnackBar(
                  //                 const SnackBar(
                  //                   content: Text(
                  //                     'Could not open maps. Please check if you have Google Maps installed or try again later.',
                  //                   ),
                  //                 ),
                  //               );
                  //             });
                  //           },
                  //           child: Container(
                  //             color: AppColors.containerColor,
                  //             margin: EdgeInsets.zero,
                  //             padding: EdgeInsets.zero,
                  //             child: const Padding(
                  //               padding: EdgeInsets.only(
                  //                   top: 4, bottom: 4, left: 8, right: 8),
                  //               child: Row(
                  //                 children: [
                  //                   Icon(
                  //                     CupertinoIcons.location_fill,
                  //                     size: 17,
                  //                   ),
                  //                   SizedBox(width: 4),
                  //                   Text(
                  //                     'Get Direction',
                  //                     style: TextStyle(
                  //                       color: AppColors.black,
                  //                       fontSize: 12,
                  //                       fontWeight: FontWeight.w600,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return InkWell(
      onTap: () {
        print(
            '🌍 Latitude: ${widget.product.latitude} 🌐 Longitude: ${widget.product.longitude}');
        showModalBottomSheet(
          context: context,
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16)),
          constraints: BoxConstraints.tight(
              Size(double.infinity, 360)), // Set fixed height
          builder: (context) => SmoothClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: Column(
                children: [
                  _buildSelectedLocationCard(context),
                ],
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons
                      .location, // Using solid variant for better visibility
                  color: AppColors.black,
                  size: 20,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 250,
                  child: Text(
                    widget.product.seller.locationName,
                    style: const TextStyle(
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                      color: Color(0xFF2F2F2F),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            Icon(
              CupertinoIcons.forward,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildSellerAvatar(),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Ionicons.person_add,
                    size: 28,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildPriceTag(),
        ],
      ),
    );
  }

  Widget _buildSellerAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        SmoothClipRRect(
          side: BorderSide(width: 1, color: AppColors.containerColor),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              context.push(Routes.anotherUserProfile);
            },
            child: Container(
              color: AppColors.white,
              margin: const EdgeInsets.only(left: 16),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 7,
                  bottom: 7,
                  left: 45,
                  right: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.seller.nickName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '138 reviews',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: Transform.translate(
            offset: Offset(-8, 0),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.containerColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: CachedNetworkImageProvider(
                  "https://${widget.product.seller.profileImagePath}",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTag() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.translate(
          offset: const Offset(-50, -8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              "Price",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: Text(
            '\$${widget.product.price}',
            style: TextStyle(
              fontSize: 24,
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            maxLines: isMore == true ? 100 : 2,
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
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => _buildReviewItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.6,
      shadowColor: AppColors.black,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isCollapsed ? Brightness.dark : Brightness.light,
      ),
      // Equal spacing from left edge
      leading: _buildAppBarButton(
        icon: CupertinoIcons.back,
        onPressed: () => context.pop(),
        isLeading: true,
      ),
      // Equal spacing from right edge
      actions: [
        _buildAppBarButton(
          useImage: true,
          imagePath: AppIcons.favorite, // Your image path here
          onPressed: () {/* Add favorite logic */},
          isLeading: false,
        ),
        const SizedBox(width: 16), // Maintain consistent right margin
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _isCollapsed
            ? Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  widget.product.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              )
            : null,
        titlePadding: const EdgeInsets.symmetric(horizontal: 54, vertical: 16),
        background: Stack(
          children: [
            _buildImageSlider(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    IconData? icon,
    String? imagePath,
    required VoidCallback onPressed,
    bool useImage = false,
    required bool isLeading,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: isLeading ? 16 : 0,
        right: 0,
        top: 8,
        bottom: 8,
      ),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: _isCollapsed
                ? AppColors.transparent
                : AppColors.containerColor.withOpacity(0.5)),
        child: Material(
          color: _isCollapsed
              ? AppColors.containerColor
              : Colors.white.withOpacity(0.5),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              child: useImage
                  ? Image.asset(
                      imagePath!,
                      width: 20,
                      height: 20,
                      color: const Color(0xFF1A1A1A),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: const Color(0xFF1A1A1A),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: widget.product.productImages.length,
          itemBuilder: (context, index) => _buildImageSlide(
            widget.product.productImages[index].url,
          ),
        ),
        _buildImageCounter(),
      ],
    );
  }

  Widget _buildImageSlide(String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductImagesDetailed(
              images: widget.product.productImages,
              initialIndex: _currentPage,
              heroTag: widget.product.id,
            ),
          ),
        );
      },
      child: SmoothClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: 'https://$imageUrl',
          filterQuality: FilterQuality.high,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildImageCounter() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black54,
            child: Text(
              '${_currentPage + 1}/${widget.product.productImages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures(enAttributes) {
    final List<String> features = [];

    enAttributes.forEach((key, values) {
      if (values.isNotEmpty) {
        if (values.length == 1) {
          features.add('$key: ${values[0]}');
        } else {
          features.add('$key: ${values.join(', ')}');
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: features.map(_buildFeatureChip).toList(),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.product.title,
        style: const TextStyle(
          fontSize: 22,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 32,
      thickness: 4,
      color: AppColors.containerColor.withOpacity(0.3),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 22, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              icon: EvaIcons.messageSquare,
              label: 'Message',
              color: AppColors.white,
              textColor: AppColors.primary,
              borderColor: AppColors.containerColor,
              onPressed: () {/* Message logic */},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildButton(
              icon: EvaIcons.phoneCall,
              label: 'Call',
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {/* Call logic */},
            ),
          ),
        ],
      ),
      //
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
      height: 44,
      child: SmoothClipRRect(
        smoothness: 0.9,
        borderRadius: BorderRadius.circular(10),
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

//
  Widget _buildReviewItem() {
    return Column(
      children: [
        SmoothClipRRect(
          side: BorderSide(width: 1, color: AppColors.containerColor),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        "https://${widget.product.productImages[0].url}",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              Icon(Icons.star,
                                  size: 16, color: AppColors.lightGray),
                              const SizedBox(width: 4),
                              Text(
                                '4.0',
                                style: TextStyle(
                                  color: AppColors.darkGray.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '2 days ago',
                      style: TextStyle(
                        color: AppColors.darkGray.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Great product! The quality is amazing and delivery was super fast. Highly recommended!',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 4,
        )
      ],
    );
  }
}

List<ProductEntity> getRecommendedProducts(String currentProductId) {
  return sampleProducts.where((p) => p.id != currentProductId).take(6).toList();
}
