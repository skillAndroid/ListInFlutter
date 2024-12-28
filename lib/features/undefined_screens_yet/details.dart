// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/undefined_screens_yet/list.dart';
import 'package:list_in/main.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final List<Product> recommendedProducts;
  final Product productDetails;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.recommendedProducts,
    required this.productDetails,
  });

  @override
  State<ProductDetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Image Carousel with Navigation
          Stack(
            children: [
              SizedBox(
                height: 350,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: widget.productDetails.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.white,
                      ),
                      child: SmoothClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.productDetails.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Top Navigation Bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black.withOpacity(0.2),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        onPressed: () {
                          // Add your photo change logic here
                        },
                        icon: Image.asset(
                          AppIcons.favorite,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.black.withOpacity(0.2),
                          shape: SmoothRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page Indicator
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothClipRRect(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        '${_currentPage + 1}/${widget.productDetails.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Product Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.productDetails.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _buildFeatureChip('Internet: Available'),
                _buildFeatureChip('Rooms: 2'),
                _buildFeatureChip('Pool: Yes'),
                _buildFeatureChip('Extra amenities: Yes'),
              ],
            ),
          ),

          const Divider(
            height: 32,
            color: AppColors.containerColor,
            thickness: 4,
          ),

          // Seller Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment
                          .centerLeft, // Align both avatar and container to the left
                      children: [
                        SmoothClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: AppColors.containerColor,
                            margin: EdgeInsets.only(
                              left: 24,
                            ), // Add margin to avoid overlap with CircleAvatar
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 7, bottom: 7, left: 45, right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Axel',
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
                                      SizedBox(
                                        width: 2,
                                      ),
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
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
                        Align(
                          alignment: Alignment
                              .centerLeft, // Vertically center the CircleAvatar
                          child: Container(
                            padding: EdgeInsets.all(
                                4), // Adjust this for the thickness of the white border
                            decoration: BoxDecoration(
                              color: AppColors
                                  .bgColor, // The color of the surrounding circle
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 28, // Inner circle radius
                              backgroundImage: CachedNetworkImageProvider(
                                widget.productDetails.images[0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Ionicons.person_add,
                      size: 34,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Transform.translate(
                      offset: Offset(-8, -12),
                      child: SmoothClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: CupertinoColors.systemYellow,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Price",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-2, 12),
                      child: Text(
                        '\$${widget.productDetails.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'I will send the Iphone 14pro Max 8/256. The color is white, It is absolutely...',
                  style: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.6),
                      fontSize: 13.5),
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'Read more',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 32,
            color: AppColors.containerColor,
            thickness: 4,
          ),

          // Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(CupertinoIcons.location,
                        color: AppColors.secondaryColor),
                    SizedBox(width: 8),
                    Text('Tashkent, Quyliq Bozor'),
                  ],
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),

          const Divider(
            height: 32,
            color: AppColors.containerColor,
            thickness: 4,
          ),

          // Similar Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: const Text(
                    'Similar posts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: widget.recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final product = widget.recommendedProducts[index];
                    return RegularProductCard(
                      product: product,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: AppColors.primary.withOpacity(0.1),
        child: Text(text,
            style: TextStyle(
              color: AppColors.primary,
            )),
      ),
    );
  }
}

List<Product> getRecommendedProducts(String currentProductId) {
  return sampleProducts.where((p) => p.id != currentProductId).take(6).toList();
}
