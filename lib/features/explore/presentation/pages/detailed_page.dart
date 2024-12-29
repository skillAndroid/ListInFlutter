// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
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
  final ValueNotifier<String?> _currentlyPlayingId =
      ValueNotifier<String?>(null);
  final ValueNotifier<Set<int>> _selectedFilters = ValueNotifier<Set<int>>({});
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
                toolbarHeight: 50,
                flexibleSpace: Column(
                  children: [
                    Container(
                      color: AppColors.bgColor,
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: FilterChip(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 12),
                              label: Text(
                                chipLabel,
                                style: TextStyle(
                                  color: selectedValue != null ||
                                          selectedValues.isNotEmpty
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                              ),
                              side: BorderSide(
                                  width: 1, color: AppColors.lightGray),
                              shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(10)),
                              selected: selectedValue != null ||
                                  selectedValues.isNotEmpty,
                              backgroundColor: AppColors.white,
                              selectedColor: AppColors.green,
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
        automaticallyImplyLeading: false,
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

  void _showSelectionBottomSheet(
      BuildContext context, AttributeModel attribute) {
    // Temporary selections map for multi-select
    Map<String, dynamic> temporarySelections = {};
    final cubit = context.read<HomeTreeCubit>();

    // Initialize temporary selections with current selections
    if (attribute.widgetType == 'multiSelectable') {
      final currentSelections = cubit.getSelectedValues(attribute);
      temporarySelections[attribute.attributeKey] =
          List<AttributeValueModel>.from(currentSelections);
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final scrollController = ScrollController();

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  attribute.helperText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              if (attribute.widgetType == 'multiSelectable' ||
                                  cubit.getSelectedAttributeValue(attribute) !=
                                      null)
                                TextButton(
                                  onPressed: () {
                                    if (attribute.widgetType ==
                                        'multiSelectable') {
                                      setState(() {
                                        temporarySelections[
                                                attribute.attributeKey] =
                                            <AttributeValueModel>[];
                                      });
                                    } else {
                                      cubit.clearSelectedAttribute(attribute);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  minWidth: 32,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      color: AppColors.white,
                      child: attribute.widgetType == 'multiSelectable'
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
                  ),
                  if (attribute.widgetType == 'multiSelectable')
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final selections =
                                    temporarySelections[attribute.attributeKey]
                                        as List<AttributeValueModel>;
                                if (selections.isEmpty) {
                                  cubit.clearSelectedAttribute(attribute);
                                } else {
                                  for (var value in selections) {
                                    cubit.selectAttributeValue(
                                        attribute, value);
                                  }
                                  cubit.confirmMultiSelection(attribute);
                                }
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
            padding: EdgeInsets.zero,
            itemCount: attribute.values.length,
            itemBuilder: (context, index) {
              final value = attribute.values[index];
              final selections = temporarySelections[attribute.attributeKey]
                  as List<AttributeValueModel>;
              final isSelected = selections.contains(value);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selections.remove(value);
                    } else {
                      selections.add(value);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.lightGray.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.black
                                : AppColors.darkGray,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.black : AppColors.grey,
                            width: 1.5,
                          ),
                          color: isSelected
                              ? AppColors.black
                              : AppColors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cubit = context.read<HomeTreeCubit>();
                        final selections =
                            temporarySelections[attribute.attributeKey]
                                as List<AttributeValueModel>;

                        if (selections.isEmpty) {
                          cubit.clearSelectedAttribute(attribute);
                        } else {
                          // Clear previous selections first
                          cubit.clearSelectedAttribute(attribute);

                          // Add new selections
                          for (var value in selections) {
                            cubit.selectAttributeValue(attribute, value);
                          }

                          // Confirm and handle dynamic attributes
                          cubit.confirmMultiSelection(attribute);
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply ${(temporarySelections[attribute.attributeKey] as List).length} selected',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.zero,
      itemCount: attribute.values.length,
      itemBuilder: (context, index) {
        final value = attribute.values[index];
        final selectedValue = cubit.getSelectedAttributeValue(attribute);
        final isSelected =
            selectedValue?.attributeValueId == value.attributeValueId;
        return InkWell(
          onTap: () {
            if (isSelected) {
              cubit.clearSelectedAttribute(attribute);
            } else {
              cubit.selectAttributeValue(attribute, value);
            }
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.lightGray.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppColors.black : AppColors.darkGray,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.black,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

//
  void _showColorSelectDialog(BuildContext context, AttributeModel attribute) {
    final cubit = context.read<HomeTreeCubit>();
    final currentValue = cubit.getSelectedAttributeValue(attribute);

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attribute.helperText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    if (currentValue != null)
                      TextButton(
                        onPressed: () {
                          cubit.clearSelectedAttribute(attribute);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: attribute.values.map((value) {
                      final isSelected =
                          cubit.isValueSelected(attribute, value);
                      final color = _parseColor(value.value);

                      return InkWell(
                        onTap: () {
                          if (isSelected) {
                            cubit.clearSelectedAttribute(attribute);
                          } else {
                            cubit.selectAttributeValue(attribute, value);
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
