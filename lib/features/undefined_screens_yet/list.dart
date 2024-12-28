// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/map/service/AppLocation.dart';
import 'package:list_in/features/undefined_screens_yet/details.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Data Classes
class AdvertisedProduct {
  final String videoUrl;
  final List<String> images;
  final String thumbnailUrl;
  final String title;
  int duration;
  final String id;
  final String userName;
  final double userRating;
  final int reviewsCount;
  final String location;
  final String price;

  AdvertisedProduct({
    required this.videoUrl,
    required this.images,
    required this.thumbnailUrl,
    required this.title,
    this.duration = 0,
    required this.id,
    required this.userName,
    required this.userRating,
    required this.reviewsCount,
    required this.location,
    required this.price,
  });
}

class Product {
  final String name;
  final List<String> images;
  final String location;
  final int price;
  final bool isNew;
  final String id;

  Product({
    required this.name,
    required this.images,
    required this.location,
    required this.price,
    required this.isNew,
    required this.id,
  });
}

class ProductListScreen extends StatefulWidget {
  final List<AdvertisedProduct> advertisedProducts;
  final List<Product> regularProducts;

  const ProductListScreen({
    super.key,
    required this.advertisedProducts,
    required this.regularProducts,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Controllers and state management
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();
  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});
  bool _isSliverAppBarVisible = true;
  // Video visibility tracking
  final Map<String, ValueNotifier<double>> _visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> _pageNotifiers = {};

  @override
  void initState() {
    super.initState();
    _initializeVideoTracking();
  }

  void _initializeVideoTracking() {
    for (var product in widget.advertisedProducts) {
      _visibilityNotifiers[product.id] = ValueNotifier<double>(0.0);
      _pageNotifiers[product.id] = ValueNotifier<int>(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _currentlyPlayingId.dispose();
    _selectedFilters.dispose();

    for (var notifier in _visibilityNotifiers.values) {
      notifier.dispose();
    }
    for (var notifier in _pageNotifiers.values) {
      notifier.dispose();
    }

    super.dispose();
  }

  void _handleVisibilityChanged(String id, double visibilityFraction) {
    if (_visibilityNotifiers[id]?.value != visibilityFraction) {
      _visibilityNotifiers[id]?.value = visibilityFraction;
      Future.microtask(() => _updateMostVisibleVideo());
    }
  }

  void _updateMostVisibleVideo() {
    String? mostVisibleId;
    double maxVisibility = 0.0;

    _visibilityNotifiers.forEach((id, notifier) {
      final visibility = notifier.value;
      final currentPage = _pageNotifiers[id]?.value ?? 0;

      if (visibility > maxVisibility && currentPage == 0 && visibility > 0.7) {
        maxVisibility = visibility;
        mostVisibleId = id;
      }
    });

    if (mostVisibleId != _currentlyPlayingId.value) {
      _currentlyPlayingId.value = mostVisibleId;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.bgColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SmoothClipRRect(
                      smoothness: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.containerColor,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                AppIcons.searchIcon,
                                width: 24,
                                height: 24,
                                color: AppColors.grey,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                cursorRadius: Radius.circular(2),
                                decoration: const InputDecoration(
                                  hintStyle:
                                      TextStyle(color: AppColors.darkGray),
                                  contentPadding: EdgeInsets.zero,
                                  hintText: "Search...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              color: AppColors.lightGray,
                              width: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            IconButton(
                              icon: Image.asset(
                                AppIcons.filterIc,
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {},
                            ),
                            SizedBox(
                              width: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.translate(
                    offset: Offset(0, 3),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            AppIcons.chatIc,
                            width: 46,
                            height: 46,
                            color: AppColors.black,
                          ),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 8,
                          bottom: 12,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Center(
                              child: const Text(
                                "2",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _selectedFilters,
      builder: (context, selectedFilters, _) {
        return Container(
          color: AppColors.bgColor,
          height: 50,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: myFilters.length,
            itemBuilder: (context, index) =>
                _buildFilterChip(index, selectedFilters),
          ),
        );
      },
    );
  }

  Widget _buildCategories() {
    final categories = [
      CategoryItem(
        title: "Food",
        imageUrl:
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200",
      ),
      CategoryItem(
        title: "Sports",
        imageUrl:
            "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=200",
      ),
      CategoryItem(
        title: "Music",
        imageUrl:
            "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200",
      ),
      CategoryItem(
        title: "Art",
        imageUrl:
            "https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=200",
      ),
      CategoryItem(
        title: "Technology",
        imageUrl:
            "https://images.unsplash.com/photo-1518997554305-5eea2f04e384?w=200",
      ),
      CategoryItem(
        title: "Travel",
        imageUrl:
            "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200",
      ),
      CategoryItem(
        title: "Fashion",
        imageUrl:
            "https://images.unsplash.com/photo-1445205170230-053b83016050?w=200",
      ),
      CategoryItem(
        title: "Books",
        imageUrl:
            "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=200",
      ),
      CategoryItem(
        title: "Fitness",
        imageUrl:
            "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=200",
      ),
      CategoryItem(
        title: "Gaming",
        imageUrl:
            "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=200",
      ),
      CategoryItem(
        title: "Nature",
        imageUrl:
            "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=200",
      ),
      CategoryItem(
        title: "Science",
        imageUrl:
            "https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=200",
      ),
    ];
    final recommendations = [
      RecommendationItem(
        title: "Recent",
        icon: Icons.access_time_rounded,
        color: Colors.blue,
      ),
      RecommendationItem(
        title: "Season Fashion",
        icon: Icons.checkroom_rounded,
        color: Colors.purple,
      ),
      RecommendationItem(
        title: "For Free",
        icon: Icons.card_giftcard_rounded,
        color: Colors.red,
      ),
      RecommendationItem(
        title: "Gift Ideas",
        icon: Icons.redeem_rounded,
        color: Colors.orange,
      ),
    ];
    return TopAppRecomendation(
      categories: categories,
      recommendations: recommendations,
    );
  }

  Widget _buildFilterChip(int index, Set<int> selectedFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: FilterChip(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 12),
        label: Text(myFilters[index].name, style: TextStyle(fontSize: 12)),
        shape: SmoothRectangleBorder(
            smoothness: 0.8, borderRadius: BorderRadius.circular(10)),
        selected: selectedFilters.contains(index),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.green,
        labelStyle: TextStyle(
          color: selectedFilters.contains(index)
              ? AppColors.white
              : AppColors.black,
        ),
        onSelected: (selected) {
          final newFilters = Set<int>.from(selectedFilters);
          if (selected) {
            newFilters.add(index);
          } else {
            newFilters.remove(index);
          }
          _selectedFilters.value = newFilters;
        },
        side: BorderSide(
            width: 1, color: AppColors.lightGray), // This removes the border
      ),
    );
  }

  Widget _buildAdvertisedProduct(AdvertisedProduct product) {
    return ValueListenableBuilder<double>(
      valueListenable: _visibilityNotifiers[product.id]!,
      builder: (context, visibility, _) {
        return VisibilityDetector(
          key: Key('detector_${product.id}'),
          onVisibilityChanged: (info) => _handleVisibilityChanged(
            product.id,
            info.visibleFraction,
          ),
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(AdvertisedProduct product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: AppColors.white,
        shape: SmoothRectangleBorder(
            smoothness: 1, borderRadius: BorderRadius.circular(6)),
        clipBehavior: Clip.hardEdge,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ValueListenableBuilder<String?>(
                valueListenable: _currentlyPlayingId,
                builder: (context, currentlyPlayingId, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _pageNotifiers[product.id]!,
                    builder: (context, currentPage, _) {
                      return Stack(
                        children: [
                          PageView.builder(
                            itemCount: product.images.length,
                            onPageChanged: (page) =>
                                _pageNotifiers[product.id]?.value = page,
                            itemBuilder: (context, index) => _buildMediaContent(
                              product,
                              index,
                              currentPage,
                              currentlyPlayingId == product.id,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SmoothClipRRect(
                                smoothness: 1,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  color: AppColors.black.withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '${currentPage + 1}/${product.images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 8, // 80% of the row's width
                        child: Text(
                          "${product.title} sotiladi yandgi ishlatilmagan",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                          width: 8), // Optional spacing between Text and Card
                      Card(
                        margin: const EdgeInsets.only(top: 2, right: 0),
                        elevation: 0,
                        shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(8)),
                        color: CupertinoColors.systemYellow,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Text(
                            'New',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            40,
                          ), // Adjust radius for desired roundness
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const Center(child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        product.userName,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        CupertinoIcons.star_fill,
                        color: CupertinoColors.systemYellow,
                        size: 22,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        product.userRating.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "(${product.reviewsCount})",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Ionicons.location,
                        size: 20,
                        color: AppColors.secondaryColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        product.location,
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Experience the pinnacle of innovation with the iPhone 15 Pro Max. Featuring a stunning titanium design, advanced A17 Pro chip for unmatched performance, an incredible 48MP camera with 5x zoom, and all-day battery life. ",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          AppIcons.favorite,
                          color: AppColors.green,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(8))),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Call Now',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(
    AdvertisedProduct product,
    int pageIndex,
    int currentPage,
    bool isPlaying,
  ) {
    if (pageIndex == 0 && isPlaying) {
      return VideoPlayerWidget(
        key: Key('video_${product.id}'),
        videoUrl: product.videoUrl,
        thumbnailUrl: product.thumbnailUrl,
        isPlaying: true,
        onPlay: () {},
        onPause: () {},
      );
    }

    return CachedNetworkImage(
      imageUrl:
          pageIndex == 0 ? product.thumbnailUrl : product.images[pageIndex],
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
        color: AppColors.white,
      )),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      extendBody: true,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverVisibilityDetector(
            key: Key('sliver-to-box-adapter'),
            onVisibilityChanged: (visibilityInfo) {
              double visiblePercentage = visibilityInfo.visibleFraction;
              setState(() {
                _isSliverAppBarVisible = visiblePercentage == 0;
              });
            },
            sliver: SliverToBoxAdapter(
              child: _buildCategories(),
            ),
          ),
          // Only show SliverAppBar when the flag is true
          if (_isSliverAppBarVisible)
            SliverAppBar(
              floating: true,
              snap: false,
              pinned: false,
              automaticallyImplyLeading: true,
              toolbarHeight: 50,
              flexibleSpace: _buildFiltersBar(),
              backgroundColor: AppColors.bgColor,
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildAdvertisedProduct(widget.advertisedProducts[index]),
                childCount: widget.advertisedProducts.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    RegularProductCard(product: widget.regularProducts[index]),
                childCount: widget.regularProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegularProductCard extends StatelessWidget {
  final Product product;

  const RegularProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          Routes.productDetails.replaceAll(':id', product.id),
          extra: getRecommendedProducts(product.id),
        );
      },
      child: Card(
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(3),
              child: Stack(
                children: [
                  SmoothClipRRect(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: CachedNetworkImage(
                        imageUrl: product.images[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: SmoothCard(
                      margin: EdgeInsets.all(0),
                      elevation: 1,
                      color: AppColors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(0.1)),
                      child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'New',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins"),
                          )),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    product.location,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          AppIcons.favorite,
                          color: AppColors.green,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Filter> myFilters = [
  Filter(name: "Category 1", value: "cat1"),
  Filter(name: "Category 2", value: "cat2"),
  Filter(name: "Category 3", value: "cat3"),
  Filter(name: "Category 4", value: "cat4"),
  Filter(name: "Category 5", value: "cat5"),
  Filter(name: "Category 6", value: "cat6"),
  Filter(name: "Category 7", value: "cat7"),
  Filter(name: "Category 8", value: "cat8"),
  // ... more filters
];

class Filter {
  final String name;
  final String value;

  Filter({required this.name, required this.value});
}

class CategoryItem {
  final String title;
  final String imageUrl;

  CategoryItem({required this.title, required this.imageUrl});
}

class TopAppRecomendation extends StatelessWidget {
  final List<CategoryItem> categories;
  final List<RecommendationItem> recommendations;

  const TopAppRecomendation({
    Key? key,
    required this.categories,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoriesList(categories: categories),
          const SizedBox(height: 16),
          const LocationBar(),
          const SizedBox(height: 16),
          RecommendationsRow(recommendations: recommendations),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class CategoriesList extends StatelessWidget {
  final List<CategoryItem> categories;

  const CategoriesList({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryRow(categories.sublist(0, 4), "Popular Categories"),
          const SizedBox(height: 12), // Increased spacing between sections
          _buildCategoryRow(categories.sublist(4, 8), "Featured Categories"),
          const SizedBox(height: 12),
          _buildCategoryRow(categories.sublist(8, 12), "More Categories"),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(List<CategoryItem> rowItems, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColor
            .withOpacity(0.5), // Light grey background for each section
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 55,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
              children: rowItems
                  .map((category) => CategoryCard(category: category))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final CategoryItem category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.reverse();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.forward();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.forward();
        },
        child: ScaleTransition(
          scale: _scaleController,
          child: SmoothClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.2),
                    offset: Offset(0, _isPressed ? 1 : 2),
                    blurRadius: _isPressed ? 2 : 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.category.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 16);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.category.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.myRedBrown,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tashkent',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Uzbekistan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_location_alt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Recommendations row with iOS-style cards
class RecommendationsRow extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const RecommendationsRow({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return RecommendationCard(item: item);
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final RecommendationItem item;

  const RecommendationCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // Add bottom padding here
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16,
                    color: item.color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
class RecommendationItem {
  final String title;
  final IconData icon;
  final Color color;

  RecommendationItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}
