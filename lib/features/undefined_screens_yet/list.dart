import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
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
  String? _currentlyPlayingId;
  String? _pendingPlayId;
  final Map<String, bool> _isItemVisible = {};
  final Map<String, int> _currentPages = {};
  final Map<String, double> _visibilityFractions = {};
  Timer? _debounceTimer;
  Timer? _playTimer;
  final ScrollController _scrollController = ScrollController();

  Set<int> selectedFilters = {};
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _playTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeState() {
    for (var product in widget.advertisedProducts) {
      _isItemVisible[product.id] = false;
      _currentPages[product.id] = 0;
      _visibilityFractions[product.id] = 0.0;
    }
  }

  void _updateMostVisibleVideo() {
    String? mostVisibleId;
    double maxVisibility = 0.0;

    _visibilityFractions.forEach((id, visibility) {
      if (visibility > maxVisibility &&
          (_currentPages[id] ?? 0) == 0 &&
          visibility > 0.7) {
        maxVisibility = visibility;
        mostVisibleId = id;
      }
    });

    // If there's a new most visible video different from what's currently playing
    if (mostVisibleId != null && mostVisibleId != _currentlyPlayingId) {
      _playTimer?.cancel();

      // Set the pending video
      setState(() {
        _pendingPlayId = mostVisibleId;
      });

      // Wait 1 second before actually playing the video
      _playTimer = Timer(const Duration(milliseconds: 100), () {
        if (_pendingPlayId == mostVisibleId) {
          // Check if it's still the most visible
          setState(() {
            _currentlyPlayingId = mostVisibleId;
            _pendingPlayId = null;
          });
        }
      });
    }
  }

  void _handleVisibilityChanged(String id, double visibilityFraction) {
    if (_visibilityFractions[id] != visibilityFraction) {
      setState(() {
        _visibilityFractions[id] = visibilityFraction;
        _isItemVisible[id] = visibilityFraction > 0;
      });

      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 150), () {
        _updateMostVisibleVideo();
      });
    }
  }

  void _handlePageChanged(String id, int pageIndex) {
    setState(() {
      _currentPages[id] = pageIndex;

      if (_currentlyPlayingId == id && pageIndex != 0) {
        _currentlyPlayingId = null;
        _pendingPlayId = null;
      } else if (pageIndex == 0) {
        _updateMostVisibleVideo();
      }
    });
  }

  Widget _buildMediaContent(AdvertisedProduct product, int pageIndex) {
    final isVisible = _isItemVisible[product.id] ?? false;
    final isCurrentPageZero = pageIndex == 0;
    final isPlaying = _currentlyPlayingId == product.id;

    if (isVisible && isCurrentPageZero && isPlaying) {
      return VideoPlayerWidget(
        key: Key('video_${product.id}'),
        videoUrl: product.videoUrl,
        thumbnailUrl: product.thumbnailUrl, // Pass the thumbnail URL
        isPlaying: true,
        onPlay: () {},
        onPause: () {},
      );
    }

    return CachedNetworkImage(
      key: Key('thumb_${product.id}'),
      imageUrl:
          isCurrentPageZero ? product.thumbnailUrl : product.images[pageIndex],
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 40,
              sigmaY: 40,
              tileMode: TileMode.clamp,
            ),
            child: AppBar(
              elevation: 2,
              // ignore: deprecated_member_use
              backgroundColor: AppColors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.bgColor.withOpacity(1),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      SmoothClipRRect(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 308,
                          alignment: Alignment.centerLeft,
                          color: AppColors.containerColor,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 248,
                                child: TextField(
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  cursorRadius: Radius.circular(2),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(right: 16),
                                    fillColor: AppColors.containerColor,
                                    icon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      child: Image.asset(
                                        width: 24,
                                        height: 24,
                                        AppIcons.searchIcon,
                                      ),
                                    ),
                                    hintText: "Search...",
                                    hintStyle: TextStyle(
                                      // ignore: deprecated_member_use
                                      color:
                                          // ignore: deprecated_member_use
                                          AppColors.darkGray.withOpacity(0.8),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    color: AppColors.lightGray,
                                    height: 24,
                                    width: 2,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Image.asset(
                                    width: 24,
                                    height: 24,
                                    AppIcons.filterIc,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Stack(
                        children: [
                          Transform.translate(
                            offset: Offset(0, 4),
                            child: Image.asset(
                              scale: 2,
                              width: 46,
                              height: 46,
                              AppIcons.chatIc,
                              color: AppColors.black,
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: SmoothClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                color: AppColors.error,
                                width: 18,
                                height: 18,
                                child: Center(
                                  child: Text(
                                    "2",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: VisibilityDetector(
              key: Key('regular_widget_1'),
              onVisibilityChanged: (VisibilityInfo info) {
                setState(() {
                  _isVisible = info.visibleFraction > 0;
                });
              },
              child: Container(
                height: 100,
                color: Colors.blue,
                child: Center(
                  child: Text("Regular Widget 1"),
                ),
              ),
            ),
          ),
          if (!_isVisible)
            SliverAppBar(
              floating: true,
              snap: false,
              pinned: false,
              expandedHeight: 30,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors
                      .bgColor, // Using theme color instead of AppColors
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: SmoothClipRRect(
                          smoothness: 1,
                          child: FilterChip(
                            disabledColor: AppColors
                                .containerColor, // Default background color for disabled state
                            backgroundColor:
                                Colors.white, // Default background color
                            selectedColor:
                                Colors.black, // Background color when selected
                            shape: SmoothRectangleBorder(
                              smoothness: 1,
                              side: BorderSide(
                                color: AppColors
                                    .lightGray, // Border color when not selected
                                width: 1.2, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                            ),

                            label: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                "Item $index",
                                style: TextStyle(
                                  color: selectedFilters.contains(index)
                                      ? Colors.white
                                      : Colors
                                          .black, // Text color changes dynamically
                                ),
                              ),
                            ),
                            selected: selectedFilters.contains(index),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedFilters.add(index);
                                } else {
                                  selectedFilters.remove(index);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = widget.advertisedProducts[index];

                  return VisibilityDetector(
                    key: Key('detector_${product.id}'),
                    onVisibilityChanged: (visibilityInfo) {
                      _handleVisibilityChanged(
                        product.id,
                        visibilityInfo.visibleFraction,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.title,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 240,
                            child: PageView.builder(
                              key: Key('pager_${product.id}'),
                              itemCount: product.images.length,
                              onPageChanged: (pageIndex) {
                                _handlePageChanged(product.id, pageIndex);
                              },
                              itemBuilder: (context, pageIndex) {
                                return _buildMediaContent(product, pageIndex);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  );
                },
                childCount: widget.advertisedProducts.length,
              ),
            ),
          ),
          // Regular Products Grid remains unchanged
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = widget.regularProducts[index];
                  return InkWell(
                    onTap: () {
                      context.push(
                        Routes.productDetails.replaceAll(':id', product.id),
                        extra: getRecommendedProducts(product.id),
                      );
                    },
                    child: SmoothClipRRect(
                      smoothness: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: Card(
                        margin: EdgeInsets.all(1),
                        elevation: 1.5,
                        shadowColor: AppColors.containerColor,
                        color: AppColors.bgColor,
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SmoothClipRRect(
                                  smoothness: 1,
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    height: 160,
                                    width: double.infinity,
                                    imageUrl: product.images[0],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  '\$${product.price}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.regularProducts.length,
              ),
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
