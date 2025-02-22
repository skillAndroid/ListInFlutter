// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

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
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/pages/filter/switch_filter_cheap.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/condition_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/numeric_fields_bototm_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/price_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/sellert_type_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DetailedPageUIState {
  final currentlyPlayingId = ValueNotifier<String?>(null);
  final selectedFilters = ValueNotifier<Set<int>>({});

  final Map<String, ValueNotifier<double>> visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> pageNotifiers = {};

  void ensureProductTrackers(String productId) {
    visibilityNotifiers.putIfAbsent(productId, () => ValueNotifier(0.0));
    pageNotifiers.putIfAbsent(productId, () => ValueNotifier(0));
  }

  double getVisibility(String id) => visibilityNotifiers[id]?.value ?? 0.0;
  int getPage(String id) => pageNotifiers[id]?.value ?? 0;
  void updateVisibility(String id, double value) {
    visibilityNotifiers[id]?.value = value;
  }

  void dispose() {
    currentlyPlayingId.dispose();
    selectedFilters.dispose();

    for (final notifier in visibilityNotifiers.values) {
      notifier.dispose();
    }
    for (final notifier in pageNotifiers.values) {
      notifier.dispose();
    }
  }
}

class DetailedSearchBarState {
  final isSearching = ValueNotifier<bool>(false);
  final searchText = ValueNotifier<String>('');
  final searchController = SearchController();

  void dispose() {
    isSearching.dispose();
    searchText.dispose();
    searchController.dispose();
  }
}

class DetailedScrollState {
  final scrollController = ScrollController();
  static const double scrollThreshold = 800.0;
  bool hasPassedThreshold = false;

  void dispose() {
    scrollController.dispose();
  }
}

class DetailedPagingState {
  final pagingController =
      PagingController<int, PublicationPairEntity>(firstPageKey: 0);

  void dispose() {
    pagingController.dispose();
  }
}

class DetailedHomeTreePage extends StatefulWidget {
  final List<ProductEntity> regularProducts;
  const DetailedHomeTreePage({
    super.key,
    required this.regularProducts,
  });

  @override
  State<DetailedHomeTreePage> createState() => _DetailedHomeTreePageState();
}

class _DetailedHomeTreePageState extends State<DetailedHomeTreePage> {
  late final DetailedPageUIState _uiState;
  late final DetailedSearchBarState _searchState;
  late final DetailedScrollState _scrollState;
  late final DetailedPagingState _pagingState;
  static const double _videoVisibilityThreshold = 0.9;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    context.read<HomeTreeCubit>().resetRequestState();
    _initializeStates();
    _setupPagingListener();
  }

  void _initializeStates() {
    _uiState = DetailedPageUIState();
    _searchState = DetailedSearchBarState();
    _scrollState = DetailedScrollState();
    _pagingState = DetailedPagingState();
  }

  void _fetchInitialData() {
    context.read<HomeTreeCubit>().fetchCatalogs();
  }

  @override
  void dispose() {
    _uiState.dispose();
    _searchState.dispose();
    _scrollState.dispose();
    _pagingState.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(String id, double visibilityFraction) {
    if (_uiState.getVisibility(id) != visibilityFraction) {
      _uiState.updateVisibility(id, visibilityFraction);
      _updateMostVisibleVideo();
    }
  }

  void _updateMostVisibleVideo() {
    String? mostVisibleId;
    double maxVisibility = 0.0;

    _uiState.visibilityNotifiers.forEach((id, notifier) {
      final visibility = notifier.value;
      final currentPage = _uiState.getPage(id);

      if (visibility > maxVisibility &&
          currentPage == 0 &&
          visibility > _videoVisibilityThreshold) {
        maxVisibility = visibility;
        mostVisibleId = id;
      }
    });

    if (mostVisibleId != _uiState.currentlyPlayingId.value) {
      _uiState.currentlyPlayingId.value = mostVisibleId;
    }
  }

  bool _shouldRebuildForState(HomeTreeState previous, HomeTreeState current) {
    final previousFilters = Set.from(previous.generateFilterParameters());
    final currentFilters = Set.from(current.generateFilterParameters());
    return !setEquals(previousFilters, currentFilters) ||
        previous.childCurrentPage != current.childCurrentPage ||
        previous.childPublicationsRequestState !=
            current.childPublicationsRequestState;
  }

  bool isFiltersRefresh = false;
  void _handleStateChanges(BuildContext context, HomeTreeState state) {
    if (isFiltersRefresh &&
            state.childPublicationsRequestState == RequestState.inProgress ||
        state.filtersTrigered) {
      _pagingState.pagingController.itemList = null;
      setState(() {
        isFiltersRefresh = false;
      });
    }
    if (state.childPublicationsRequestState == RequestState.error) {
      _handleError(state);
    } else if (state.childPublicationsRequestState == RequestState.completed) {
      _handleCompletedState(state);
    }
  }

  void _handleError(HomeTreeState state) {
    _pagingState.pagingController.error =
        state.errorChildPublicationsFetch ?? 'An unknown error occurred';
  }

  void _handleCompletedState(HomeTreeState state) {
    final items = state.childPublications;

    if (items.isEmpty) {
      _pagingState.pagingController.appendPage([], 0);
      return;
    }

    _updatePagingControllerItems(state);
  }

  void _updatePagingControllerItems(HomeTreeState state) {
    final items = state.childPublications;
    final isLastPage = state.childHasReachedMax;
    final currentPage = state.childCurrentPage;

    if (isLastPage) {
      _pagingState.pagingController.appendLastPage(items);
    } else {
      _pagingState.pagingController.appendPage(items, currentPage + 1);
    }
  }

  void _setupPagingListener() {
    _pagingState.pagingController.addPageRequestListener((pageKey) {
      if (context.read<HomeTreeCubit>().state.childPublicationsRequestState !=
          RequestState.inProgress) {
        context.read<HomeTreeCubit>().fetchChildPage(pageKey);
      }
    });
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(body: Progress());
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(error)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeTreeCubit, HomeTreeState>(
      listenWhen: _shouldRebuildForState,
      listener: _handleStateChanges,
      builder: (context, state) {
        final attributes = state.orderedAttributes;
        final numericFields = state.numericFields;
        if (state.isLoading) return _buildLoadingScreen();
        if (state.error != null) return _buildErrorScreen(state.error!);
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: _buildAppBar(state),
          body: RefreshIndicator(
            color: Colors.blue,
            backgroundColor: AppColors.white,
            elevation: 1,
            strokeWidth: 3,
            displacement: 40,
            edgeOffset: 10,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () =>
                Future.sync(() => _pagingState.pagingController.refresh()),
            child: CustomScrollView(
              controller: _scrollState.scrollController,
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
                          itemCount:
                              attributes.length + numericFields.length + 5,
                          itemBuilder: (context, index) {
                            debugPrint("😤😤${numericFields.length}");
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
                                    color: AppColors.lightGray.withOpacity(0.7),
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

                            if (index <= attributes.length) {
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
                              if (attribute.filterWidgetType ==
                                  'oneSelectable') {
                                // For single select, show selected value name if selected
                                chipLabel = selectedValue?.value ??
                                    attribute.filterText;
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
                                      color: colorMap[
                                              selectedValues.first.value] ??
                                          Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: (colorMap[selectedValues
                                                    .first.value] ==
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
                                                color: colorMap[
                                                        selectedValues[i]
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
                                      width: 1,
                                      color:
                                          AppColors.lightGray.withOpacity(0.7)),
                                  shape: SmoothRectangleBorder(
                                    smoothness: 0.8,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selected: selectedValue != null,
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.white,
                                  onSelected: (_) {
                                    if (attribute.values.isNotEmpty &&
                                        mounted) {
                                      _showAttributeSelectionUI(
                                          context, attribute);
                                    }
                                  },
                                ),
                              );
                            }

                            if (index ==
                                attributes.length + numericFields.length + 1) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.5),
                                child: FilterChip(
                                  showCheckmark: false,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  label: Text(
                                    _getConditionText(state.condition),
                                    style: TextStyle(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  side: BorderSide(
                                    width: 1,
                                    color: AppColors.lightGray.withOpacity(0.7),
                                  ),
                                  shape: SmoothRectangleBorder(
                                    smoothness: 0.8,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selected: state.condition != 'ALL',
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.white,
                                  onSelected: (_) =>
                                      _showConditionBottomSheet(context),
                                ),
                              );
                            }

                            if (index ==
                                attributes.length + numericFields.length + 2) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.5),
                                child: FilterChip(
                                  showCheckmark: false,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  label: Text(
                                    _getSellerTypeText(state.sellerType),
                                    style: TextStyle(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  side: BorderSide(
                                      width: 1,
                                      color:
                                          AppColors.lightGray.withOpacity(0.7)),
                                  shape: SmoothRectangleBorder(
                                    smoothness: 0.8,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selected: state.sellerType != SellerType.ALL,
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.white,
                                  onSelected: (_) =>
                                      _showSellerTypeBottomSheet(context),
                                ),
                              );
                            }

                            if (index ==
                                attributes.length + numericFields.length + 3) {
                              return SwitchFilterChip(
                                label: 'Bargain',
                                value: state.bargain,
                                onChanged: (value) => context
                                    .read<HomeTreeCubit>()
                                    .toggleBargain(value, false, "CHILD"),
                              );
                            }

                            if (index ==
                                attributes.length + numericFields.length + 4) {
                              return SwitchFilterChip(
                                label: 'Is Free',
                                value: state.isFree,
                                onChanged: (value) => context
                                    .read<HomeTreeCubit>()
                                    .toggleIsFree(value, false, "CHILD"),
                              );
                            }

                            final numericFieldIndex =
                                index - attributes.length - 1;
                            final numericField =
                                numericFields[numericFieldIndex];
                            final fieldValues =
                                state.numericFieldValues[numericField.id];

                            String chipLabel = numericField.fieldName;
                            if (fieldValues != null) {
                              final from = fieldValues['from'];
                              final to = fieldValues['to'];

                              if (from != null && to != null) {
                                chipLabel = '$from - $to';
                              } else if (from != null) {
                                chipLabel = '≥ $from';
                              } else if (to != null) {
                                chipLabel = '≤ $to';
                              }
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: FilterChip(
                                showCheckmark: false,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                label: Text(
                                  chipLabel,
                                  style: TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                                side: BorderSide(
                                    width: 1,
                                    color:
                                        AppColors.lightGray.withOpacity(0.7)),
                                shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                selected: fieldValues != null,
                                backgroundColor: AppColors.white,
                                selectedColor: AppColors.white,
                                onSelected: (_) {
                                  _showNumericFieldBottomSheet(
                                      context, numericField);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.white,
                ),
                _buildProductGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConditionBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(14)),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const ConditionBottomSheet(
          page: "CHILD",
        ),
      ),
    );
  }

  String _getConditionText(String? condition) {
    switch (condition) {
      case 'NEW_PRODUCT':
        return 'New';
      case 'USED_PRODUCT':
        return 'Used';
      default:
        return 'Condition';
    }
  }

  void _showSellerTypeBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(14)),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const SellerTypeBottomSheet(
          page: "CHILD",
        ),
      ),
    );
  }

  void _showPriceRangeBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PriceRangeBottomSheet(
            page: "CHILD",
          ),
        ),
      ),
    );
  }

  void _showNumericFieldBottomSheet(
      BuildContext context, NomericFieldModel field) {
    final cubit = context.read<HomeTreeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NumericFieldBottomSheet(
            field: field,
            initialValues: cubit.state.numericFieldValues[field.id],
            onRangeSelected: (from, to) {
              cubit.setNumericFieldRange(field.id, from, to);
            },
          ),
        ),
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
        backgroundColor: AppColors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
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
                          context.pushNamed(
                            RoutesByName.search,
                            extra: {
                              'priceFrom': state.priceFrom,
                              'priceTo': state.priceTo,
                              'filterState': {
                                'bargain': state.bargain,
                                'isFree': state.isFree,
                                'condition': state.condition,
                                'sellerType': state.sellerType,
                              },
                            },
                          );
                        },
                        child: SmoothClipRRect(
                          smoothness: 0.8,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 52,
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
                                    "What are you looking for?",
                                    style: TextStyle(
                                      color:
                                          AppColors.darkGray.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    IconButton(
                      icon: Image.asset(
                        AppIcons.filterIc,
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        final homeTreeCubit =
                            BlocProvider.of<HomeTreeCubit>(context);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          showDragHandle: false,
                          enableDrag: false,
                          shape: SmoothRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          builder: (context) => BlocProvider.value(
                            value:
                                homeTreeCubit, // Provide the same cubit instance
                            child: SmoothClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: FractionallySizedBox(
                                heightFactor: 1,
                                child: FiltersPage(page: "detailed"),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      width: 2,
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
      sliver: PagedSliverList(
        pagingController: _pagingState.pagingController,
        builderDelegate: PagedChildBuilderDelegate(
          firstPageProgressIndicatorBuilder: (_) => const Progress(),
          newPageProgressIndicatorBuilder: (_) => const Progress(),
          itemBuilder: (context, item, index) {
            final currentItem = item as PublicationPairEntity;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: currentItem.isSponsored
                  ? _buildAdvertisedProduct(currentItem.firstPublication)
                  : Row(
                      children: [
                        Expanded(
                          child: ProductCardContainer(
                            key: ValueKey(
                                'regular_${currentItem.firstPublication.id}'),
                            product: currentItem.firstPublication,
                          ),
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: currentItem.secondPublication != null
                              ? ProductCardContainer(
                                  key: ValueKey(
                                      'regular_${currentItem.secondPublication!.id}'),
                                  product: currentItem.secondPublication!,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
            );
          },
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            error: _pagingState.pagingController.error,
            onTryAgain: () => _pagingState.pagingController.refresh(),
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              const Center(child: Text('No items found')),
        ),
      ),
    );
  }

  Widget _buildAdvertisedProduct(GetPublicationEntity product) {
    _uiState.ensureProductTrackers(product.id);

    return ValueListenableBuilder<double>(
      valueListenable: _uiState.visibilityNotifiers[product.id]!,
      builder: (context, visibility, _) {
        return VisibilityDetector(
          key: Key('detector_${product.id}'),
          onVisibilityChanged: (info) => _handleVisibilityChanged(
            product.id,
            info.visibleFraction,
          ),
          child: OptimizedAdvertisedCard(
            product: product,
            currentlyPlayingId: _uiState.currentlyPlayingId,
          ),
        );
      },
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
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: StatefulBuilder(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                                        cubit.fetchChildPage(0);
                                        setState(() {
                                          isFiltersRefresh = true;
                                        });
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
                                  else if (cubit.getSelectedAttributeValue(
                                          attribute) !=
                                      null)
                                    TextButton(
                                      onPressed: () {
                                        cubit.clearSelectedAttribute(attribute);
                                        cubit.fetchChildPage(0);
                                        setState(() {
                                          isFiltersRefresh = true;
                                        });
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
          ),
        );
      },
    );
  }

  String _getSellerTypeText(SellerType type) {
    switch (type) {
      case SellerType.ALL:
        return 'Shop Type';
      case SellerType.INDIVIDUAL_SELLER:
        return 'Individual';
      case SellerType.BUSINESS_SELLER:
        return 'Shop';
    }
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
                            fontWeight: FontWeight.w500,
                          ),
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

                  cubit.fetchChildPage(0);
                  setState(() {
                    isFiltersRefresh = true;
                  });
                  cubit.getAtributesForPost();
                } else {
                  cubit.clearSelectedAttribute(attribute);
                  for (var value in selections) {
                    cubit.selectAttributeValue(attribute, value);
                  }

                  cubit.fetchChildPage(0);
                  setState(() {
                    isFiltersRefresh = true;
                  });
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

                cubit.fetchChildPage(0);
                setState(() {
                  isFiltersRefresh = true;
                });
              } else {
                cubit.selectAttributeValue(attribute, value);

                cubit.fetchChildPage(0);
                setState(() {
                  isFiltersRefresh = true;
                });
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
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: StatefulBuilder(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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

                                cubit.fetchChildPage(0);
                                setState(() {
                                  isFiltersRefresh = true;
                                });
                              } else {
                                cubit.clearSelectedAttribute(attribute);
                                for (var value in selections) {
                                  cubit.selectAttributeValue(attribute, value);
                                }

                                cubit.fetchChildPage(0);
                                setState(() {
                                  isFiltersRefresh = true;
                                });
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
          ),
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
}
