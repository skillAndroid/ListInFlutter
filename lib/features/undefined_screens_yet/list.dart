import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
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
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        elevation: 2,
        backgroundColor: AppColors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.containerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              AppIcons.searchIcon,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
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
                          IconButton(
                            icon: Image.asset(
                              AppIcons.filterIc,
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
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
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "2",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildFiltersBar() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _selectedFilters,
      builder: (context, selectedFilters, _) {
        return SizedBox(
          height: 44,
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

  Widget _buildFilterChip(int index, Set<int> selectedFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(myFilters[index].name),
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

//

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
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Second SliverAppBar for filters
          SliverAppBar(
            floating: true,
            snap: false,
            pinned: false,
            automaticallyImplyLeading: true,
            toolbarHeight: 60,
            flexibleSpace: _buildFiltersBar(),
            backgroundColor: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: product.images[0],
              fit: BoxFit.cover,
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
