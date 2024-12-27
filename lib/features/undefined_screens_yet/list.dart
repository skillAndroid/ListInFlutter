import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
                                color: AppColors.gray,
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
          height: 46,
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
    return Container(
      height: 90,
      color: AppColors.white,
      child: Text('Just testing for now'),
    );
  }

  Widget _buildFilterChip(int index, Set<int> selectedFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(myFilters[index].name),
        shape: SmoothRectangleBorder(
            smoothness: 1, borderRadius: BorderRadius.circular(8)),
        selected: selectedFilters.contains(index),
        backgroundColor: AppColors.containerColor,
        selectedColor: AppColors.black,
        labelStyle: TextStyle(
          color: selectedFilters.contains(index) ? Colors.white : Colors.black,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              product.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ValueListenableBuilder<String?>(
              valueListenable: _currentlyPlayingId,
              builder: (context, currentlyPlayingId, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _pageNotifiers[product.id]!,
                  builder: (context, currentPage, _) {
                    return PageView.builder(
                      itemCount: product.images.length,
                      onPageChanged: (page) =>
                          _pageNotifiers[product.id]?.value = page,
                      itemBuilder: (context, index) => _buildMediaContent(
                        product,
                        index,
                        currentPage,
                        currentlyPlayingId == product.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
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
              toolbarHeight: 44,
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

// Ai
