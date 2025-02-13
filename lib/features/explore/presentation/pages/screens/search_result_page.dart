// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

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
import 'package:list_in/features/explore/presentation/pages/screens/detailed_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/widgets/advertised_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
      PagingController<int, PublicationPairEntity>(firstPageKey: 0);

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
    _pagingState.pagingController.error =
        state.errorSearchPublicationsFetch ?? 'An unknown error occurred';
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 6,
          color: AppColors.black,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: 1,
                              itemBuilder: (context, index) {
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
                              }),
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
                        onPressed: () {
                          context.read<HomeTreeCubit>().clearSearchText();
                          context.pop();
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(RoutesByName.search);
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
                                  child: Image.asset(
                                    AppIcons.searchIcon,
                                    width: 24,
                                    height: 24,
                                    color: AppColors.darkGray.withOpacity(0.8),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    state.searchText != null
                                        ? state.searchText.toString()
                                        : "What are you looking for?", // Show current search text or default
                                    style: TextStyle(
                                      color: AppColors.black,
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
                          child: RemouteRegularProductCard2(
                            key: ValueKey(
                                'regular_${currentItem.firstPublication.id}'),
                            product: currentItem.firstPublication,
                          ),
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: currentItem.secondPublication != null
                              ? RemouteRegularProductCard2(
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
          child: AdvertisedProductCard(
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
        child: BlocProvider.value(value: cubit, child: PriceRangeBottomSheet()),
      ),
    );
  }
}
