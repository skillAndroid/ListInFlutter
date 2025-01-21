// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/undefined_screens_yet/video_player.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DetailedHomeTreePage extends StatefulWidget {
  final List<AdvertisedProductEntity> advertisedProducts;
  final List<ProductEntity> regularProducts;
  const DetailedHomeTreePage({
    super.key,
    required this.advertisedProducts,
    required this.regularProducts,
  });

  @override
  State<DetailedHomeTreePage> createState() => _DetailedHomeTreePageState();
}

class _DetailedHomeTreePageState extends State<DetailedHomeTreePage> {
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();
  final PagingController<int, GetPublicationEntity> _pagingController =
      PagingController(firstPageKey: 0);

  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});
  final Map<String, ValueNotifier<double>> _visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> _pageNotifiers = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeTreeCubit>().resetRequestState();
    _pagingController.addPageRequestListener((pageKey) {
      final currentState = context.read<HomeTreeCubit>().state;
      if (currentState.childPublicationsRequestState !=
              RequestState.inProgress &&
          !currentState.childHasReachedMax) {
        context.read<HomeTreeCubit>().fetchChildPage(pageKey);
      }
    });
    _initializeVideoTracking();
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

    // Remove any listeners if needed

    // Dispose controllers
    _scrollController.dispose();
    _searchController.dispose();
    _pagingController.dispose();
    // Safely dispose notifiers
    if (_currentlyPlayingId.hasListeners) {
      _currentlyPlayingId.dispose();
    }

    if (_selectedFilters.hasListeners) {
      _selectedFilters.dispose();
    }

    // Dispose map notifiers
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
      listenWhen: (previous, current) {
        final previousFilters = Set.from(previous.generateFilterParameters());
        final currentFilters = Set.from(current.generateFilterParameters());
        return !setEquals(previousFilters, currentFilters) || // Filter changes
            previous.childPublicationsRequestState !=
                current.childPublicationsRequestState;
      },
      listener: (context, state) {
        // If this is a new filter request (page 0), clear the paging controller
        if (state.childCurrentPage == 0 &&
            state.childPublicationsRequestState == RequestState.inProgress) {
          _pagingController.itemList = null; // Clear existing items
        }

        if (state.childPublicationsRequestState == RequestState.error) {
          _pagingController.error =
              state.errorChildPublicationsFetch ?? 'An unknown error occurred';
        } else if (state.childPublicationsRequestState ==
            RequestState.completed) {
          final isLastPage = state.childHasReachedMax;
          final newItems = state.childPublications;

          if (isLastPage) {
            _pagingController.appendLastPage(newItems);
          } else {
            _pagingController.appendPage(newItems, state.childCurrentPage + 1);
          }
        }
      },
      builder: (context, state) {
        final attributes = state.orderedAttributes;
        return Scaffold(
          appBar: _buildAppBar(state),
          body: RefreshIndicator(
            onRefresh: () => Future.sync(() => _pagingController.refresh()),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 50,
                  flexibleSpace: Column(
                    children: [
                      Container(
                        color: AppColors.bgColor,
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: attributes.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.5),
                                child: FilterChip(
                                  showCheckmark: false,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 10,
                                  ),
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Price",
                                        style: TextStyle(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  side: BorderSide(
                                    width: 1,
                                    color: AppColors.lightGray,
                                  ),
                                  shape: SmoothRectangleBorder(
                                    smoothness: 0.8,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selected: state.priceFrom != null ||
                                      state.priceTo != null,
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.white,
                                  onSelected: (_) =>
                                      _showPriceRangeBottomSheet(context),
                                ),
                              );
                            }

                            final attribute = attributes[index - 1];
                            final cubit = context.read<HomeTreeCubit>();
                            final selectedValue =
                                cubit.getSelectedAttributeValue(attribute);
                            final selectedValues =
                                cubit.getSelectedValues(attribute);

                            // Color mapping
                            final Map<String, Color> colorMap = {
                              'Silver': Colors.grey[300]!,
                              'Pink': Colors.pink,
                              'Rose Gold': Color(0xFFB76E79),
                              'Space Gray': Color(0xFF4A4A4A),
                              'Blue': Colors.blue,
                              'Yellow': Colors.yellow,
                              'Green': Colors.green,
                              'Purple': Colors.purple,
                              'White': Colors.white,
                              'Red': Colors.red,
                              'Black': Colors.black,
                            };

                            // Determine chip label based on selection type and count
                            String chipLabel;
                            if (attribute.filterWidgetType == 'oneSelectable') {
                              // For single select, show selected value name if selected
                              chipLabel =
                                  selectedValue?.value ?? attribute.filterText;
                            } else {
                              // For multi-select types
                              if (selectedValues.isEmpty) {
                                chipLabel = attribute.filterText;
                              } else if (selectedValues.length == 1) {
                                // Show single selected value name
                                chipLabel = selectedValues.first.value;
                              } else {
                                // Show count for multiple selections
                                chipLabel =
                                    '${attribute.filterText}(${selectedValues.length})';
                              }
                            }

                            Widget? colorIndicator;
                            if (attribute.filterWidgetType ==
                                    'colorMultiSelectable' &&
                                selectedValues.isNotEmpty) {
                              if (selectedValues.length == 1) {
                                // Single color indicator
                                colorIndicator = Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color:
                                        colorMap[selectedValues.first.value] ??
                                            Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: (colorMap[
                                                  selectedValues.first.value] ==
                                              Colors.white)
                                          ? Colors.grey
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                );
                              } else {
                                // Stacked color indicators
                                colorIndicator = SizedBox(
                                  width: 40,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      for (int i = 0;
                                          i < selectedValues.length;
                                          i++)
                                        Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: i * 7.0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: colorMap[selectedValues[i]
                                                      .value] ??
                                                  Colors.grey,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: (colorMap[
                                                            selectedValues[i]
                                                                .value] ==
                                                        Colors.white)
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: FilterChip(
                                showCheckmark: false,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (colorIndicator != null) ...[
                                      colorIndicator,
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      chipLabel,
                                      style: TextStyle(
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                side: BorderSide(
                                    width: 1, color: AppColors.lightGray),
                                shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                selected: selectedValue != null,
                                backgroundColor: AppColors.white,
                                selectedColor: AppColors.white,
                                onSelected: (_) {
                                  if (attribute.values.isNotEmpty && mounted) {
                                    _showAttributeSelectionUI(
                                        context, attribute);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                      child: GestureDetector(
                        onTap: () {
                          context.push(Routes.search);
                        },
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
                                      color:
                                          AppColors.darkGray.withOpacity(0.8)),
                                ),
                                Expanded(
                                  child: Text(
                                    "What are you looking for?", // Show current search text or default
                                    style: TextStyle(
                                      color:
                                          AppColors.darkGray.withOpacity(0.8),
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

  void _showSelectionBottomSheet(
      BuildContext context, AttributeModel attribute) {
    Map<String, dynamic> temporarySelections = {};
    final cubit = context.read<HomeTreeCubit>();

    if (attribute.filterWidgetType == 'multiSelectable') {
      // Create a deep copy of current selections to avoid modifying the original state
      final currentSelections = cubit.getSelectedValues(attribute);
      temporarySelections[attribute.attributeKey] =
          List<AttributeValueModel>.from(currentSelections);
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: SmoothRectangleBorder(
        smoothness: 0.8,
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double calculateInitialSize(List<dynamic> values) {
              if (values.length >= 20) return 0.9;
              if (values.length >= 15) return 0.8;
              if (values.length >= 10) return 0.65;
              if (values.length >= 5) return 0.53;
              return values.length * 0.12;
            }

            return DraggableScrollableSheet(
              initialChildSize: calculateInitialSize(attribute.values),
              maxChildSize: attribute.values.length >= 20
                  ? 0.9
                  : calculateInitialSize(attribute.values),
              minChildSize: 0,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // New toolbar with centered title
                    SizedBox(
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Centered title
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                attribute.filterText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Left and right buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                if (attribute.filterWidgetType ==
                                        'multiSelectable' &&
                                    cubit
                                        .getSelectedValues(attribute)
                                        .isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      cubit.clearSelectedAttribute(attribute);
                                      cubit.getAtributesForPost();
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      foregroundColor: AppColors.black,
                                    ),
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                else if (cubit
                                        .getSelectedAttributeValue(attribute) !=
                                    null)
                                  TextButton(
                                    onPressed: () {
                                      cubit.clearSelectedAttribute(attribute);
                                      cubit.getAtributesForPost();
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 0),
                                      foregroundColor: AppColors.black,
                                    ),
                                    child: Text(
                                      'clear',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.containerColor,
                    ),
                    Expanded(
                      child: attribute.filterWidgetType == 'multiSelectable'
                          ? _buildMultiSelectList(
                              context,
                              attribute,
                              scrollController,
                              temporarySelections,
                              setState,
                            )
                          : _buildSingleSelectList(
                              context,
                              attribute,
                              scrollController,
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
    Map<String, dynamic> temporarySelections,
    StateSetter setState,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: attribute.values.length,
            itemBuilder: (context, index) {
              final value = attribute.values[index];
              final selections = temporarySelections[attribute.attributeKey]
                      as List<AttributeValueModel>? ??
                  [];

              final isSelected = selections.contains(value);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selections.remove(value);
                      } else {
                        selections.add(value);
                      }
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightGray,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 17,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          value.value,
                          style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.darkBackgroundGray,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 8),
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<HomeTreeCubit>();
                final selections = temporarySelections[attribute.attributeKey]
                    as List<AttributeValueModel>;

                if (selections.isEmpty) {
                  cubit.clearSelectedAttribute(attribute);
                  cubit.getAtributesForPost();
                } else {
                  cubit.clearSelectedAttribute(attribute);
                  for (var value in selections) {
                    cubit.selectAttributeValue(attribute, value);
                  }
                  cubit.confirmMultiSelection(attribute);
                  cubit.getAtributesForPost();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply (${(temporarySelections[attribute.attributeKey] as List).length})',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    final cubit = context.read<HomeTreeCubit>();
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: attribute.values.length,
      itemBuilder: (context, index) {
        final value = attribute.values[index];
        final selectedValue = cubit.getSelectedAttributeValue(attribute);
        final isSelected =
            selectedValue?.attributeValueId == value.attributeValueId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isSelected) {
                cubit.clearSelectedAttribute(attribute);
              } else {
                cubit.selectAttributeValue(attribute, value);
              }
              Navigator.pop(context);
              cubit.getAtributesForPost();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.value,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isSelected ? AppColors.black : AppColors.darkGray,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.transparent,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : AppColors.white,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 17,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorMultiSelectDialog(
      BuildContext context, AttributeModel attribute) {
    final cubit = context.read<HomeTreeCubit>();
    Map<String, dynamic> temporarySelections = {};

    // Initialize temporary selections with current selections
    final currentSelections = cubit.getSelectedValues(attribute);
    temporarySelections[attribute.attributeKey] =
        List<AttributeValueModel>.from(currentSelections);

    final Map<String, Color> colorMap = {
      'Silver': Colors.grey[300]!,
      'Pink': Colors.pink,
      'Rose Gold': Color(0xFFB76E79),
      'Space Gray': Color(0xFF4A4A4A),
      'Blue': Colors.blue,
      'Yellow': Colors.yellow,
      'Green': Colors.green,
      'Purple': Colors.purple,
      'White': Colors.white,
      'Red': Colors.red,
      'Black': Colors.black,
    };

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: SmoothRectangleBorder(
        smoothness: 0.8,
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double calculateInitialSize(List<dynamic> values) {
              if (values.length >= 20) return 0.9;
              if (values.length >= 15) return 0.8;
              if (values.length >= 10) return 0.65;
              if (values.length >= 5) return 0.5;
              return values.length * 0.08;
            }

            return DraggableScrollableSheet(
              initialChildSize: calculateInitialSize(attribute.values),
              maxChildSize: attribute.values.length >= 20
                  ? 0.9
                  : calculateInitialSize(attribute.values),
              minChildSize: 0,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                attribute.filterText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Ionicons.close),
                                  onPressed: () => Navigator.pop(context),
                                  color: AppColors.black,
                                ),
                                if (cubit
                                    .getSelectedValues(attribute)
                                    .isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      cubit.clearAllSelectedAttributes();
                                      cubit.getAtributesForPost();
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      foregroundColor: AppColors.black,
                                    ),
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.containerColor,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: attribute.values.length,
                        itemBuilder: (context, index) {
                          final value = attribute.values[index];
                          final selections =
                              temporarySelections[attribute.attributeKey]
                                      as List<AttributeValueModel>? ??
                                  [];
                          final isSelected = selections.contains(value);
                          final color = colorMap[value.value] ?? Colors.grey;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selections.remove(value);
                                  } else {
                                    selections.add(value);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color == Colors.white
                                              ? Colors.grey
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        value.value,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isSelected
                                              ? AppColors.black
                                              : AppColors.darkGray,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.lightGray,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.white,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 17,
                                              color: AppColors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 32, top: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            final cubit = context.read<HomeTreeCubit>();
                            final selections =
                                temporarySelections[attribute.attributeKey]
                                    as List<AttributeValueModel>;

                            if (selections.isEmpty) {
                              cubit.clearSelectedAttribute(attribute);
                            } else {
                              cubit.clearSelectedAttribute(attribute);
                              for (var value in selections) {
                                cubit.selectAttributeValue(attribute, value);
                              }
                              cubit.confirmMultiSelection(attribute);
                              cubit.getAtributesForPost(); // Add this line
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Apply (${(temporarySelections[attribute.attributeKey] as List).length})',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }

  void _showAttributeSelectionUI(
      BuildContext context, AttributeModel attribute) {
    switch (attribute.filterWidgetType) {
      case 'colorMultiSelectable':
        _showColorMultiSelectDialog(context, attribute);
        break;
      case 'oneSelectable':
      case 'multiSelectable':
        _showSelectionBottomSheet(context, attribute);
        break;
    }
  }

  void _showPriceRangeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PriceRangeBottomSheet(),
      ),
    );
  }
}

// Price formatter utility
String formatPrice(String value) {
  if (value.isEmpty) return '';

  // Convert to number and back to string to remove any non-numeric characters
  final number = double.tryParse(value.replaceAll(' ', ''));
  if (number == null) return value;

  // Convert to int to remove decimal places and format with spaces
  final parts = number.toInt().toString().split('').reversed.toList();

  String formatted = '';
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && i % 3 == 0) {
      formatted = ' $formatted';
    }
    formatted = parts[i] + formatted;
  }

  return formatted;
}

class PriceRangeBottomSheet extends StatefulWidget {
  const PriceRangeBottomSheet({super.key});

  @override
  _PriceRangeBottomSheetState createState() => _PriceRangeBottomSheetState();
}

class _PriceRangeBottomSheetState extends State<PriceRangeBottomSheet> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late HomeTreeState currentState;

  @override
  void initState() {
    super.initState();
    currentState = context.read<HomeTreeCubit>().state;
    _fromController = TextEditingController(
      text: currentState.priceFrom?.toInt().toString() ?? '',
    );
    _toController = TextEditingController(
      text: currentState.priceTo?.toInt().toString() ?? '',
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onFromChanged(String value) {
    final formatted = formatPrice(value);
    if (formatted != value) {
      _fromController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onToChanged(String value) {
    final formatted = formatPrice(value);
    if (formatted != value) {
      _toController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmoothClipRRect(
      smoothness: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with close button and title
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(-4, 0),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.only(),
                        constraints: BoxConstraints(),
                        splashRadius: 24,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.read<HomeTreeCubit>().clearPriceRange();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // Centered title
                  Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Price range inputs
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fromController,
                          keyboardType: TextInputType.number,
                          onChanged: _onFromChanged,
                          decoration: InputDecoration(
                            labelText: 'From',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 8,
                          height: 2,
                          color: Colors.grey[300],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _toController,
                          keyboardType: TextInputType.number,
                          onChanged: _onToChanged,
                          decoration: InputDecoration(
                            labelText: 'To',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apply button at the bottom
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final from = double.tryParse(
                          _fromController.text.replaceAll(' ', ''));
                      final to = double.tryParse(
                          _toController.text.replaceAll(' ', ''));
                      context.read<HomeTreeCubit>().setPriceRange(from, to);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: SmoothRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            )
          ],
        ),
      ),
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
