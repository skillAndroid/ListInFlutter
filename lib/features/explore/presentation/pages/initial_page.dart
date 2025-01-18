// catalog_list_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/top_app_recomendation.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:list_in/features/video/presentation/wigets/scrollable_list.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class InitialHomeTreePage extends StatefulWidget {
  final List<AdvertisedProductEntity> advertisedProducts;
  final List<ProductEntity> regularProducts;
  const InitialHomeTreePage({
    super.key,
    required this.advertisedProducts,
    required this.regularProducts,
  });

  @override
  State<InitialHomeTreePage> createState() => _InitialHomeTreePageState();
}

class _InitialHomeTreePageState extends State<InitialHomeTreePage> {
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();
  final PagingController<int, GetPublicationEntity> _pagingController =
      PagingController(firstPageKey: 0);

  bool _isSliverAppBarVisible = false;
  final double _scrollThreshold = 800.0;
  bool _hasPassedThreshold = false;

  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});

  final Map<String, ValueNotifier<double>> _visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> _pageNotifiers = {};

  @override
  void initState() {
    super.initState();
    _initializeVideoTracking();
    // Add page request listener
    _pagingController.addPageRequestListener((pageKey) {
      // Prevent duplicate requests for the same page
      if (!context.read<HomeTreeCubit>().state.isPublicationsLoading) {
        context.read<HomeTreeCubit>().fetchPage(pageKey);
      }
    });

    // Trigger initial load
    Future.microtask(() => _pagingController.refresh());

    _initializeScrollListener();
    context.read<HomeTreeCubit>().fetchCatalogs();
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      final currentPosition = _scrollController.position.pixels;

      if (currentPosition > _scrollThreshold && !_hasPassedThreshold) {
        _hasPassedThreshold = true;
        setState(() => _isSliverAppBarVisible = true);
      } else if (currentPosition < _scrollThreshold && _hasPassedThreshold) {
        _hasPassedThreshold = false;
        setState(() => _isSliverAppBarVisible = false);
      }
    });
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
    _scrollController.dispose();
    _pagingController.dispose();
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

//
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeTreeCubit, HomeTreeState>(
      listenWhen: (previous, current) =>
          previous.errorPublicationsFetch != current.errorPublicationsFetch ||
          previous.publications != current.publications ||
          previous.hasReachedMax != current.hasReachedMax,
      listener: (context, state) {
        final error = state.errorPublicationsFetch;
        if (error != null) {
          _pagingController.error = error;
        } else {
          final isLastPage = state.hasReachedMax;
          final currentPage = state.currentPage;
          final newItems = state.publications;

          if (currentPage == 0) {
            if (isLastPage) {
              _pagingController.appendLastPage(newItems);
            } else {
              _pagingController.appendPage(newItems, currentPage + 1);
            }
          } else {
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
        if (state.isLoading) {
          return Scaffold(
            body: Center(
              child: Transform.scale(
                scale: 0.75,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: AppColors.black,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
          );
        }

        if (state.error != null) {
          return Scaffold(
            body: Center(
                child: Column(
              children: [
                Text(state.error!),
              ],
            )),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bgColor,
          extendBody: true,
          appBar: _buildAppBar(),
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Video Posts",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        VideoCarousel(
                          items: widget.advertisedProducts,
                        ),
                        SizedBox(
                          height: 16,
                        )
                      ],
                    ),
                  ),
                ),
                _buildProductGrid()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        sliver: PagedSliverMasonryGrid<int, GetPublicationEntity>(
          pagingController: _pagingController,
          gridDelegateBuilder: (context) =>
              SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
          ),
          builderDelegate: PagedChildBuilderDelegate<GetPublicationEntity>(
            itemBuilder: (context, publication, index) {
              return _buildDynamicTile(publication);
            },
            firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
              error: _pagingController.error,
              onTryAgain: () => _pagingController.refresh(),
            ),
            noItemsFoundIndicatorBuilder: (context) =>
                const Center(child: Text("No items found")),
          ),
        ));
  }

  Widget _buildDynamicTile(GetPublicationEntity publication) {
    if (publication.videoUrl == null) {
      // Regular item (smaller size)
      return Card(
        child: ListTile(
          title: Text(publication.title),
          subtitle: Text(publication.description),
        ),
      );
    } else {
      // Large item (spans full width)
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmoothClipRRect(
              smoothness: 1,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                child: publication.productImages.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: 'https://${publication.productImages[0].url}',
                        fit: BoxFit.cover,

                        // Show a loading spinner while the image is loading
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.transparent,
                          ),
                        ),
                        // Handle errors with a custom error widget
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200], // Light grey background
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Image.asset(
                        AppImages.appLogo,
                        fit: BoxFit.cover,
                        // Error handling for asset image
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Logo not found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            Text(
              publication.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(publication.description),
            const SizedBox(height: 8),
            const Icon(Icons.play_circle_fill, size: 32),
          ],
        ),
      );
    }
  }
// other functions :

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
            itemCount: state.catalogs?.length,
            itemBuilder: (context, index) =>
                _buildFilterChip(state, index, selectedFilters),
          ),
        );
      },
    );
  }

  //
  Widget _buildFilterChip(
      HomeTreeState state, int index, Set<int> selectedFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: FilterChip(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 12),
        label:
            Text(state.catalogs![index].name, style: TextStyle(fontSize: 12)),
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
          context.read<HomeTreeCubit>().selectCatalog(state.catalogs![index]);
          context.goNamed(RoutesByName.subcategories);
        },
        side: BorderSide(width: 1, color: AppColors.lightGray),
      ),
    );
  }
//

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
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildAdvertisedProduct(AdvertisedProductEntity product) {
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

  Widget _buildProductCard(AdvertisedProductEntity product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shadowColor: AppColors.black.withOpacity(0.2),
        color: AppColors.white,
        shape: SmoothRectangleBorder(
            smoothness: 1, borderRadius: BorderRadius.circular(4)),
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
                          "${product.title} sotiladi yandgi ishlatilmagan",
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
                        product.userRating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.green,
                        ),
                      ),
                      Text(
                        "(${product.reviewsCount})",
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
                        product.location,
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
                    "Experience the pinnacle of innovation with the iPhone 15 Pro Max. Featuring a stunning titanium design, advanced A17 Pro chip for unmatched performance, an incredible 48MP camera with 5x zoom, and all-day battery life. ",
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
                        product.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
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
    AdvertisedProductEntity product,
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
    return TopAppRecomendationCategory(
      recommendations: recommendations,
    );
  }
}

//
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
