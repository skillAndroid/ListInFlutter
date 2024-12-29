// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
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
  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});
  bool _isSliverAppBarVisible = true;
  final Map<String, ValueNotifier<double>> _visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> _pageNotifiers = {};

  @override
  void initState() {
    super.initState();
    context.read<HomeTreeCubit>().fetchCatalogs();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        final attributes = state.allAttributes;

        return Scaffold(
          appBar: _buildAppBar(),
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
                flexibleSpace: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: attributes.length,
                        itemBuilder: (context, index) {
                          final attribute = attributes[index];
                          final selectedValue = context
                              .read<HomeTreeCubit>()
                              .getSelectedAttributeValue(attribute);
                          final selectedValues = context
                              .read<HomeTreeCubit>()
                              .getSelectedValues(attribute);

                          String chipLabel = attribute.helperText;
                          if (attribute.widgetType == 'multiSelectable' &&
                              selectedValues.isNotEmpty) {
                            chipLabel =
                                '${attribute.helperText} (${selectedValues.length})';
                          } else if (selectedValue != null) {
                            chipLabel = selectedValue.value;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                chipLabel,
                                style: TextStyle(
                                  color: selectedValue != null ||
                                          selectedValues.isNotEmpty
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                              ),
                              selected: selectedValue != null ||
                                  selectedValues.isNotEmpty,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              onSelected: (_) {
                                if (attribute.values.isNotEmpty) {
                                  _showAttributeSelectionUI(context, attribute);
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAdvertisedProduct(
                        widget.advertisedProducts[index]),
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
                    (context, index) => RegularProductCard(
                        product: widget.regularProducts[index]),
                    childCount: widget.regularProducts.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
//

//
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

//
//
  Widget _buildProductCard(AdvertisedProductEntity product) {
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

  void _showSelectionBottomSheet(
      BuildContext context, AttributeModel attribute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      routeSettings: const RouteSettings(name: '/attribute_sheet'),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            attribute.helperText,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: attribute.widgetType == 'multiSelectable'
                        ? _buildMultiSelectList(
                            context, attribute, scrollController)
                        : _buildSingleSelectList(
                            context, attribute, scrollController),
                  ),
                  if (attribute.widgetType == 'multiSelectable')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context
                                    .read<HomeTreeCubit>()
                                    .clearSelection(attribute);
                              },
                              child: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                context
                                    .read<HomeTreeCubit>()
                                    .confirmMultiSelection(attribute);
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
//
//
  void _showColorSelectDialog(BuildContext context, AttributeModel attribute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attribute.helperText),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: attribute.values.map((value) {
                  final isSelected = context
                      .read<HomeTreeCubit>()
                      .isValueSelected(attribute, value);
                  return InkWell(
                    onTap: () {
                      context
                          .read<HomeTreeCubit>()
                          .selectAttributeValue(attribute, value);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(value.value),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _isLightColor(_parseColor(value.value))
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  void _showAttributeSelectionUI(
      BuildContext context, AttributeModel attribute) {
    switch (attribute.widgetType) {
      case 'colorSelectable':
        _showColorSelectDialog(context, attribute);
        break;
      case 'oneSelectable':
      case 'multiSelectable':
        _showSelectionBottomSheet(context, attribute);
        break;
    }
  }

  Widget _buildMultiSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListView.builder(
          controller: scrollController,
          itemCount: attribute.values.length,
          itemBuilder: (context, index) {
            final value = attribute.values[index];
            final isSelected =
                context.read<HomeTreeCubit>().isValueSelected(attribute, value);

            return CheckboxListTile(
              title: Text(value.value),
              value: isSelected,
              onChanged: (bool? checked) {
                context
                    .read<HomeTreeCubit>()
                    .selectAttributeValue(attribute, value);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSingleSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
      itemCount: attribute.values.length,
      itemBuilder: (context, index) {
        final value = attribute.values[index];
        final isSelected =
            context.read<HomeTreeCubit>().isValueSelected(attribute, value);

        return ListTile(
          title: Text(value.value),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            context
                .read<HomeTreeCubit>()
                .selectAttributeValue(attribute, value);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('FF${colorString.substring(1)}', radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
//
