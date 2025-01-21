// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/top_app_bar_recomendation_sub.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChildHomeTreePage extends StatefulWidget {
  final List<AdvertisedProductEntity> advertisedProducts;
  final List<ProductEntity> regularProducts;
  const ChildHomeTreePage({
    super.key,
    required this.advertisedProducts,
    required this.regularProducts,
  });

  @override
  State<ChildHomeTreePage> createState() => _InitialHomeTreePageState();
}

class _InitialHomeTreePageState extends State<ChildHomeTreePage> {
  final ScrollController _scrollController = ScrollController();

  final PagingController<int, GetPublicationEntity> _pagingController =
      PagingController(firstPageKey: 0);
  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});
  bool _isSliverAppBarVisible = false;
  final double _scrollThreshold = 800.0;
  bool _hasPassedThreshold = false;

  final Map<String, ValueNotifier<double>> _visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> _pageNotifiers = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      if (context
              .read<HomeTreeCubit>()
              .state
              .secondaryPublicationsRequestState !=
          RequestState.inProgress) {
        context.read<HomeTreeCubit>().fetchSecondaryPage(pageKey);
      }
    });
    _initializeVideoTracking();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!mounted) return;

    final currentPosition = _scrollController.position.pixels;
    if (currentPosition > _scrollThreshold && !_hasPassedThreshold) {
      _hasPassedThreshold = true;
      setState(() {
        _isSliverAppBarVisible = true;
      });
    } else if (currentPosition < _scrollThreshold && _hasPassedThreshold) {
      _hasPassedThreshold = false;
      setState(() {
        _isSliverAppBarVisible = false;
      });
    }
  }

  void _initializeVideoTracking() {
    if (!mounted) return;

    for (var product in widget.advertisedProducts) {
      if (!_visibilityNotifiers.containsKey(product.id)) {
        _visibilityNotifiers[product.id] = ValueNotifier<double>(0.0);
      }
      if (!_pageNotifiers.containsKey(product.id)) {
        _pageNotifiers[product.id] = ValueNotifier<int>(0);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _scrollController.removeListener(_handleScroll);

    _scrollController.dispose();
    _pagingController.dispose();

    if (_currentlyPlayingId.hasListeners) {
      _currentlyPlayingId.dispose();
    }

    if (_selectedFilters.hasListeners) {
      _selectedFilters.dispose();
    }

    for (var notifier in _visibilityNotifiers.values) {
      if (notifier.hasListeners) {
        notifier.dispose();
      }
    }
    _visibilityNotifiers.clear();

    for (var notifier in _pageNotifiers.values) {
      if (notifier.hasListeners) {
        notifier.dispose();
      }
    }
    _pageNotifiers.clear();

    super.dispose();
  }

  void _handleVisibilityChanged(String id, double visibilityFraction) {
    if (_isDisposed || !mounted) return;

    final notifier = _visibilityNotifiers[id];
    if (notifier != null &&
        notifier.hasListeners &&
        notifier.value != visibilityFraction) {
      notifier.value = visibilityFraction;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateMostVisibleVideo();
          }
        });
      }
    }
  }

  void _updateMostVisibleVideo() {
    if (_isDisposed || !mounted) return;

    String? mostVisibleId;
    double maxVisibility = 0.0;

    for (var entry in _visibilityNotifiers.entries) {
      if (!entry.value.hasListeners) continue;

      final visibility = entry.value.value;
      final pageNotifier = _pageNotifiers[entry.key];
      if (pageNotifier == null || !pageNotifier.hasListeners) continue;

      final currentPage = pageNotifier.value;

      if (visibility > maxVisibility && currentPage == 0 && visibility > 0.7) {
        maxVisibility = visibility;
        mostVisibleId = entry.key;
      }
    }

    if (mostVisibleId != _currentlyPlayingId.value &&
        _currentlyPlayingId.hasListeners) {
      _currentlyPlayingId.value = mostVisibleId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeTreeCubit, HomeTreeState>(
      listenWhen: (previous, current) =>
          previous.secondaryPublicationsRequestState !=
              current.secondaryPublicationsRequestState ||
          previous.secondaryPublications != current.secondaryPublications ||
          previous.secondaryHasReachedMax != current.secondaryHasReachedMax,
      listener: (context, state) {
        if (state.secondaryPublicationsRequestState == RequestState.error) {
          _pagingController.error = state.errorSecondaryPublicationsFetch ??
              'An unknown error occurred';
        } else if (state.secondaryPublicationsRequestState ==
            RequestState.completed) {
          // Handle empty search results
          if (state.secondaryPublications.isEmpty &&
              state.secondarySearchRequestState == RequestState.inProgress) {
            _pagingController.refresh();
            return;
          }

          final isLastPage = state.secondaryHasReachedMax;
          final currentPage = state.secondaryCurrentPage;
          final newItems = state.secondaryPublications;

          if (currentPage == 0) {
            if (isLastPage) {
              _pagingController.appendLastPage(newItems);
            } else {
              _pagingController.appendPage(newItems, currentPage + 1);
            }
          } else {
            // Calculate items for the current page
            final startIndex = currentPage * HomeTreeCubit.pageSize;
            final newPageItems = newItems.skip(startIndex).toList();

            if (isLastPage) {
              _pagingController.appendLastPage(newPageItems);
            } else {
              _pagingController.appendPage(newPageItems, currentPage + 1);
            }
          }
        }
      },
      builder: (context, state) {
        if (state.error != null) {
          return Scaffold(
            body: Center(child: Text(state.error!)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bgColor,
          extendBody: true,
          appBar: _buildAppBar(state),
          body: RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildCategories(),
                ),
                if (_isSliverAppBarVisible)
                  SliverAppBar(
                    floating: true,
                    snap: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 50,
                    flexibleSpace: _buildFiltersBar(state),
                    backgroundColor: AppColors.bgColor,
                  ),
                _buildProductGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersBar(HomeTreeState state) {
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
            itemCount: state.selectedCatalog?.childCategories.length,
            itemBuilder: (context, index) =>
                _buildFilterChip(state, index, selectedFilters),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      HomeTreeState state, int index, Set<int> selectedFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: FilterChip(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 12),
        label: Text(state.selectedCatalog!.childCategories[index].name,
            style: TextStyle(fontSize: 12)),
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
          context.read<HomeTreeCubit>().selectChildCategory(
              state.selectedCatalog!.childCategories[index]);
          context.goNamed(RoutesByName.attributes);
        },
        side: BorderSide(width: 1, color: AppColors.lightGray),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(HomeTreeState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: Offset(-10, 0),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.black,
                        ),
                      ),
                    ),
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
                                child: Image.asset(AppIcons.searchIcon,
                                    width: 24,
                                    height: 24,
                                    color: AppColors.darkGray.withOpacity(0.8)),
                              ),
                              Expanded(
                                child: Text(
                                  "What are you looking for?", // Show current search text or default
                                  style: TextStyle(
                                    color: AppColors.darkGray.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      sliver: PagedSliverList<int, GetPublicationEntity>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<GetPublicationEntity>(
          itemBuilder: (context, item, index) {
            final items = _pagingController.itemList;
            if (items == null) return const SizedBox.shrink();

            final screenWidth = MediaQuery.of(context).size.width;

            if (index == 0) {
              _processItems(items);
            }

            return _buildProcessedItem(index, items, screenWidth);
          },
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            error: _pagingController.error,
            onTryAgain: () => _pagingController.refresh(),
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              const Center(child: Text('No items found')),
        ),
      ),
    );
  }

  late final List<_ProcessedItem> _processedItems = [];

  void _processItems(List<GetPublicationEntity> items) {
    _processedItems.clear();

    // Separate regular and video items
    final regularItems = <GetPublicationEntity>[];
    final videoItems = <GetPublicationEntity>[];

    for (final item in items) {
      if (item.videoUrl?.isNotEmpty ?? false) {
        videoItems.add(item);
      } else {
        regularItems.add(item);
      }
    }

    // Process regular items in pairs
    for (int i = 0; i < regularItems.length; i += 2) {
      if (i + 1 < regularItems.length) {
        // Create pair
        _processedItems.add(
          _ProcessedItem(
            type: ItemType.regularPair,
            leftItem: regularItems[i],
            rightItem: regularItems[i + 1],
          ),
        );
      } else {
        // Last single regular item - keep it as a regular row item
        _processedItems.add(
          _ProcessedItem(
            type: ItemType
                .regularPair, // Using regularPair type but with no rightItem
            leftItem: regularItems[i],
          ),
        );
      }
    }

    // Add video items
    for (final videoItem in videoItems) {
      _processedItems.add(
        _ProcessedItem(
          type: ItemType.advertisedProduct,
          leftItem: videoItem,
        ),
      );
    }
  }

  Widget _buildProcessedItem(
      int index, List<GetPublicationEntity> items, double screenWidth) {
    if (index >= _processedItems.length) return const SizedBox.shrink();

    final processedItem = _processedItems[index];

    switch (processedItem.type) {
      case ItemType.regularPair:
        return _buildProductRow(
          leftItem: processedItem.leftItem,
          rightItem: processedItem.rightItem,
          screenWidth: screenWidth,
        );

      case ItemType.advertisedProduct:
        return SizedBox(
          width: screenWidth,
          child: _buildAdvertisedProduct(processedItem.leftItem),
        );
    }
  }

  Widget _buildProductRow({
    required GetPublicationEntity leftItem,
    GetPublicationEntity? rightItem,
    required double screenWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: RemouteRegularProductCard(
              key: ValueKey('regular_${leftItem.id}'),
              product: leftItem,
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: rightItem != null
                ? RemouteRegularProductCard(
                    key: ValueKey('regular_${rightItem.id}'),
                    product: rightItem,
                  )
                : const SizedBox(), // Empty space for single items
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisedProduct(GetPublicationEntity product) {
    // Add null check and initialization if needed
    if (!_visibilityNotifiers.containsKey(product.id)) {
      _visibilityNotifiers[product.id] = ValueNotifier<double>(0.0);
    }

    return ValueListenableBuilder<double>(
      valueListenable: _visibilityNotifiers[product.id]!, // Now safe to use !
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

  Widget _buildProductCard(GetPublicationEntity product) {
    if (!_pageNotifiers.containsKey(product.id)) {
      _pageNotifiers[product.id] = ValueNotifier<int>(0);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shadowColor: AppColors.black.withOpacity(0.2),
        color: AppColors.white,
        shape: SmoothRectangleBorder(
            smoothness: 0.8, borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: ValueListenableBuilder<String?>(
                valueListenable: _currentlyPlayingId,
                builder: (context, currentlyPlayingId, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _pageNotifiers[product.id]!,
                    builder: (context, currentPage, _) {
                      return Stack(
                        children: [
                          PageView.builder(
                            itemCount: product.productImages.length,
                            onPageChanged: (page) =>
                                _pageNotifiers[product.id]?.value = page,
                            itemBuilder: (context, index) => _buildMediaContent(
                              product,
                              index,
                              currentPage,
                              currentlyPlayingId == product.id,
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.only(top: 8, left: 8),
                            elevation: 0,
                            shape: SmoothRectangleBorder(
                                smoothness: 1,
                                borderRadius: BorderRadius.circular(6)),
                            color: AppColors.primary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                'New',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
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
                                    '${currentPage + 1}/${product.productImages.length}',
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
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 6,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            // color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                          width: 8), // Optional spacing between Text and Card
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            40,
                          ), // Adjust radius for desired roundness
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://${product.seller.profileImagePath}",
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
                        product.seller.nickName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.green,
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
                        " 4",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        "5",
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
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
                        width: 5,
                      ),
                      Icon(
                        Ionicons.location,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        product.locationName,
                        style: TextStyle(
                          color: AppColors.darkGray.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGray.withOpacity(0.7),
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
                      color: AppColors.darkGray.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.price.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.primary,
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
                  SizedBox(
                    height: 4,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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

//
  Widget _buildMediaContent(
    GetPublicationEntity product,
    int pageIndex,
    int currentPage,
    bool isPlaying,
  ) {
    if (pageIndex == 0 && isPlaying) {
      return VideoPlayerWidget(
        key: Key('video_${product.id}'),
        videoUrl: "https://${product.videoUrl!}",
        thumbnailUrl: 'https://${product.productImages[0].url}',
        isPlaying: true,
        onPlay: () {},
        onPause: () {},
      );
    }

    return CachedNetworkImage(
      imageUrl: pageIndex == 0
          ? "https://${product.productImages[0].url}"
          : "https://${product.productImages[pageIndex].url}",
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
        color: AppColors.white,
      )),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.error)),
    );
  }

//
//
  Widget _buildCategories() {
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
    return TopAppRecomendationSubCategory(
      recommendations: recommendations,
    );
  }
}

class ErrorIndicator extends StatelessWidget {
  final dynamic error;
  final VoidCallback onTryAgain;

  const ErrorIndicator({
    super.key,
    required this.error,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error.toString()),
          ElevatedButton(
            onPressed: onTryAgain,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  const NoItemsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No items found'),
    );
  }
}

enum ItemType {
  regularPair,
  advertisedProduct,
}

class _ProcessedItem {
  final ItemType type;
  final GetPublicationEntity leftItem;
  final GetPublicationEntity? rightItem;

  _ProcessedItem({
    required this.type,
    required this.leftItem,
    this.rightItem,
  });
}
