import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:list_in/video_player.dart';
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
    // Rest of the build method remains unchanged
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
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
                      SizedBox(
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
                    ],
                  ),
                );
              },
              childCount: widget.advertisedProducts.length,
            ),
          ),
          // Regular Products Grid remains unchanged
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = widget.regularProducts[index];
                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        height: 150,
                        width: double.infinity,
                        imageUrl: product.images[0],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                );
              },
              childCount: widget.regularProducts.length,
            ),
          ),
        ],
      ),
    );
  }
}
