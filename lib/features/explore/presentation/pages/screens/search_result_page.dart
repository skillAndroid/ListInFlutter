// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/pages/filter/switch_filter_cheap.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/condition_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/price_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/sellert_type_bottom_sheet.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPageUIState {
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

class SearchSearchBarState {
  final isSearching = ValueNotifier<bool>(false);
  final searchText = ValueNotifier<String>('');
  final searchController = SearchController();

  void dispose() {
    isSearching.dispose();
    searchText.dispose();
    searchController.dispose();
  }
}

class SearchScrollState {
  final scrollController = ScrollController();
  static const double scrollThreshold = 800.0;
  bool hasPassedThreshold = false;

  void dispose() {
    scrollController.dispose();
  }
}

class SearchPagingState {
  final pagingController =
      PagingController<int, GetPublicationEntity>(firstPageKey: 0);

  void dispose() {
    pagingController.dispose();
  }
}

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({
    super.key,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final SearchPageUIState _uiState;
  late final SearchSearchBarState _searchState;
  late final SearchScrollState _scrollState;
  late final SearchPagingState _pagingState;
  static const double _videoVisibilityThreshold = 1;

  @override
  void initState() {
    super.initState();
    _initializeStates();
    _setupPagingListener();
  }

  void _initializeStates() {
    _uiState = SearchPageUIState();
    _searchState = SearchSearchBarState();
    _scrollState = SearchScrollState();
    _pagingState = SearchPagingState();
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
        previous.searchCurrentPage != current.searchCurrentPage ||
        previous.searchPublicationsRequestState !=
            current.searchPublicationsRequestState ||
        previous.searchHasReachedMax != current.searchHasReachedMax;
  }

  void _handleStateChanges(BuildContext context, HomeTreeState state) {
    if (state.filtersTrigered) {
      _pagingState.pagingController.itemList = null;
    }
    if (state.searchPublicationsRequestState == RequestState.error) {
      _handleError(state);
    } else if (state.searchPublicationsRequestState == RequestState.completed) {
      _handleCompletedState(state);
    }
  }

  void _handleError(HomeTreeState state) {
    _pagingState.pagingController.error = state.errorSearchPublicationsFetch ??
        AppLocalizations.of(context)!.unknown_error;
  }

  void _handleCompletedState(HomeTreeState state) {
    final items = state.searchPublications;

    if (items.isEmpty) {
      _pagingState.pagingController.appendPage([], 0);
      return;
    }

    _updatePagingControllerItems(state);
  }

  void _updatePagingControllerItems(HomeTreeState state) {
    final items = state.searchPublications;
    final isLastPage = state.searchHasReachedMax;
    final currentPage = state.searchCurrentPage;

    if (isLastPage) {
      _pagingState.pagingController.appendLastPage(items);
    } else {
      _pagingState.pagingController.appendPage(items, currentPage + 1);
    }
  }

  void _setupPagingListener() {
    _pagingState.pagingController.addPageRequestListener((pageKey) {
      if (context.read<HomeTreeCubit>().state.searchPublicationsRequestState !=
          RequestState.inProgress) {
        context.read<HomeTreeCubit>().searchPage(pageKey);
      }
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 6,
          color: Theme.of(context).colorScheme.secondary,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(error)],
        ),
      ),
    );
  }

  Future<void> _onPop() async {
    context.read<HomeTreeCubit>().clearSearchText();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _onPop();
        return true;
      },
      child: BlocConsumer<HomeTreeCubit, HomeTreeState>(
        listenWhen: _shouldRebuildForState,
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state.isLoading) return _buildLoadingScreen();
          if (state.error != null) return _buildErrorScreen(state.error!);
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(state),
            body: RefreshIndicator(
              color: Colors.blue,
              backgroundColor: Theme.of(context).cardColor,
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
                            color: Theme.of(context).scaffoldBackgroundColor,
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.5),
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
                                            AppLocalizations.of(context)!.price,
                                            style: TextStyle(
                                              color: state.priceFrom != null ||
                                                      state.priceTo != null
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      side: BorderSide(
                                        width: 1,
                                        color: Theme.of(context).cardColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      selectedColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      selected: state.priceFrom != null ||
                                          state.priceTo != null,
                                      onSelected: (_) =>
                                          _showPriceRangeBottomSheet(context),
                                    ),
                                  );
                                }

                                if (index == 1) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.5),
                                    child: FilterChip(
                                      showCheckmark: false,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 10,
                                      ),
                                      label: Text(
                                        _getConditionText(state.condition),
                                        style: TextStyle(
                                          color: state.condition != 'ALL'
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                        ),
                                      ),
                                      side: BorderSide(
                                        width: 1,
                                        color: Theme.of(context).cardColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      selectedColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      selected: state.condition != 'ALL',
                                      onSelected: (_) =>
                                          _showConditionBottomSheet(context),
                                    ),
                                  );
                                }

                                if (index == 3) {
                                  return SwitchFilterChip(
                                    label:
                                        AppLocalizations.of(context)!.bargain,
                                    value: state.bargain,
                                    onChanged: (value) => context
                                        .read<HomeTreeCubit>()
                                        .toggleBargain(
                                            value, false, 'SEARCH_RESULT'),
                                  );
                                }

                                if (index == 4) {
                                  return SwitchFilterChip(
                                    label: 'Is Free',
                                    value: state.isFree,
                                    onChanged: (value) => context
                                        .read<HomeTreeCubit>()
                                        .toggleIsFree(
                                            value, false, 'SEARCH_RESULT'),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.5),
                                  child: FilterChip(
                                    showCheckmark: false,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 10,
                                    ),
                                    label: Text(
                                      _getSellerTypeText(state.sellerType),
                                      style: TextStyle(
                                        color:
                                            state.sellerType != SellerType.ALL
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                      ),
                                    ),
                                    side: BorderSide(
                                      width: 1,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    selectedColor:
                                        Theme.of(context).colorScheme.secondary,
                                    selected:
                                        state.sellerType != SellerType.ALL,
                                    onSelected: (_) =>
                                        _showSellerTypeBottomSheet(context),
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                    backgroundColor: AppColors.transparent,
                  ),
                  _buildProductGrid(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getConditionText(String? condition) {
    switch (condition) {
      case 'NEW_PRODUCT':
        return AppLocalizations.of(context)!.condition_new;
      case 'USED_PRODUCT':
        return AppLocalizations.of(context)!.condition_used;
      default:
        return AppLocalizations.of(context)!.condition;
    }
  }

  String _getSellerTypeText(SellerType type) {
    switch (type) {
      case SellerType.ALL:
        return AppLocalizations.of(context)!.seller_type;
      case SellerType.INDIVIDUAL_SELLER:
        return AppLocalizations.of(context)!.individual;
      case SellerType.BUSINESS_SELLER:
        return AppLocalizations.of(context)!.shop;
    }
  }

  PreferredSizeWidget _buildAppBar(HomeTreeState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        onPressed: () {
                          context.read<HomeTreeCubit>().clearSearchText();
                          context.pop();
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).colorScheme.secondary,
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
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 16,
                            cornerSmoothing: 0.7,
                          ),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    AppIcons.searchIcon,
                                    width: 24,
                                    height: 24,
                                    color: AppColors.darkGray.withOpacity(0.8),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    state.searchText != null
                                        ? state.searchText.toString()
                                        : AppLocalizations.of(context)!
                                            .whatAreYouLookingFor,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                    SizedBox(
                      width: 6,
                    ),
                    IconButton(
                      icon: Image.asset(
                        AppIcons.filterIc,
                        width: 24,
                        height: 24,
                        color: Theme.of(context).colorScheme.secondary,
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
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 14,
                              cornerSmoothing: 0.7,
                            ),
                          ),
                          builder: (context) => BlocProvider.value(
                            value:
                                homeTreeCubit, // Provide the same cubit instance
                            child: ClipSmoothRect(
                              radius: SmoothBorderRadius(
                                cornerRadius: 18,
                                cornerSmoothing: 0.7,
                              ),
                              child: FractionallySizedBox(
                                heightFactor: 1,
                                child: FiltersPage(page: "result_page"),
                              ),
                            ),
                          ),
                        );
                      },
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: PagedSliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 0,
        pagingController: _pagingState.pagingController,
        builderDelegate: PagedChildBuilderDelegate<GetPublicationEntity>(
          firstPageProgressIndicatorBuilder: (_) => const Progress(),
          newPageProgressIndicatorBuilder: (_) => const Progress(),
          itemBuilder: (context, publication, index) {
            // Determine if item should use advertised card based on video URL
            final bool isAdvertised = publication.videoUrl != null;

            return isAdvertised
                ? _buildAdvertisedProduct(
                    publication,
                  )
                : ProductCardContainer(
                    key: ValueKey('regular_${publication.id}'),
                    product: publication,
                  );
          },
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            error: _pagingState.pagingController.error,
            onTryAgain: () => _pagingState.pagingController.refresh(),
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              Center(child: Text(AppLocalizations.of(context)!.no_items_found)),
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

  void _showPriceRangeBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocProvider.value(
            value: cubit,
            child: PriceRangeBottomSheet(
              page: 'SEARCH_RESULT',
            )),
      ),
    );
  }

  void _showConditionBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 14,
          cornerSmoothing: 0.7,
        ),
      ),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const ConditionBottomSheet(
          page: 'SEARCH_RESULT',
        ),
      ),
    );
  }

  void _showSellerTypeBottomSheet(BuildContext context) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 14,
          cornerSmoothing: 0.7,
        ),
      ),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const SellerTypeBottomSheet(
          page: 'SEARCH_RESULT',
        ),
      ),
    );
  }
}
