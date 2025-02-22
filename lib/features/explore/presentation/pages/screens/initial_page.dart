// catalog_list_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/top_app_recomendation.dart';
import 'package:list_in/features/video/presentation/wigets/scrollable_list.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePageUIState {
  final currentlyPlayingId = ValueNotifier<String?>(null);
  final selectedFilters = ValueNotifier<Set<int>>({});
  final _isSliverAppBarVisible = ValueNotifier<bool>(false);
  final Map<String, ValueNotifier<double>> visibilityNotifiers = {};
  final Map<String, ValueNotifier<int>> pageNotifiers = {};

  bool get isSliverAppBarVisible => _isSliverAppBarVisible.value;
  set isSliverAppBarVisible(bool value) => _isSliverAppBarVisible.value = value;

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
    _isSliverAppBarVisible.dispose();
    for (final notifier in visibilityNotifiers.values) {
      notifier.dispose();
    }
    for (final notifier in pageNotifiers.values) {
      notifier.dispose();
    }
  }
}

class SearchBarState {
  final isSearching = ValueNotifier<bool>(false);
  final searchText = ValueNotifier<String>('');
  final searchController = SearchController();

  void dispose() {
    isSearching.dispose();
    searchText.dispose();
    searchController.dispose();
  }
}

class ScrollState {
  final scrollController = ScrollController();
  // Using ValueNotifier<bool> for minimal state updates
  final isAppBarVisible = ValueNotifier<bool>(false);
  static const double scrollThreshold = 800.0;

  // Add debouncing to prevent rapid consecutive updates
  Timer? _scrollTimer;

  void setupScrollListener() {
    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    // Cancel any pending timer
    _scrollTimer?.cancel();

    // Debounce the scroll updates
    _scrollTimer = Timer(const Duration(milliseconds: 0), () {
      final currentPosition = scrollController.position.pixels;
      final shouldShowAppBar = currentPosition > scrollThreshold;

      // Only update if the value actually changed
      if (isAppBarVisible.value != shouldShowAppBar) {
        isAppBarVisible.value = shouldShowAppBar;
      }
    });
  }

  void dispose() {
    _scrollTimer?.cancel();
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    isAppBarVisible.dispose();
  }
}

class PagingState {
  final pagingController =
      PagingController<int, PublicationPairEntity>(firstPageKey: 0);

  void dispose() {
    pagingController.dispose();
  }
}

class InitialHomeTreePage extends StatefulWidget {
  final List<ProductEntity> regularProducts;

  const InitialHomeTreePage({
    super.key,
    required this.regularProducts,
  });

  @override
  State<InitialHomeTreePage> createState() => _InitialHomeTreePageState();
}

class _InitialHomeTreePageState extends State<InitialHomeTreePage> {
  late final HomePageUIState _uiState;
  late final SearchBarState _searchState;
  late final ScrollState _scrollState;
  late final PagingState _pagingState;

  static const double _videoVisibilityThreshold = 0.9;

  @override
  void initState() {
    super.initState();
    _initializeStates();
    _setupListeners();
    _fetchInitialData();
    _fetchVideoFeeds();
  }

  void _initializeStates() {
    _uiState = HomePageUIState();
    _searchState = SearchBarState();
    _scrollState = ScrollState();
    _pagingState = PagingState();
  }

  void _setupListeners() {
    _scrollState.setupScrollListener();
    _setupPagingListener();
  }

  void _setupPagingListener() {
    _pagingState.pagingController.addPageRequestListener((pageKey) {
      if (context.read<HomeTreeCubit>().state.initialPublicationsRequestState !=
          RequestState.inProgress) {
        context.read<HomeTreeCubit>().fetchInitialPage(pageKey);
      }
    });
  }

  void _fetchInitialData() {
    context.read<HomeTreeCubit>().fetchCatalogs();
  }

  void _fetchVideoFeeds() {
    context.read<HomeTreeCubit>().fetchVideoFeeds(0);
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

  // in initial page :
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeTreeCubit, HomeTreeState>(
      listenWhen: _shouldRebuildForState,
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state.isLoading) return _buildLoadingScreen();
        if (state.error != null) return _buildErrorScreen(state.error!);

        return _buildMainScreen(state);
      },
    );
  }

  bool _shouldRebuildForState(HomeTreeState previous, HomeTreeState current) {
    return previous.initialPublicationsRequestState !=
            current.initialPublicationsRequestState ||
        previous.initialPublications.length !=
            current.initialPublications.length ||
        previous.initialHasReachedMax != current.initialHasReachedMax;
  }

  void _handleStateChanges(BuildContext context, HomeTreeState state) {
    if (state.initialPublicationsRequestState == RequestState.error) {
      _handleError(state);
    } else if (state.initialPublicationsRequestState ==
        RequestState.completed) {
      _handleCompletedState(state);
    }
  }

  void _handleError(HomeTreeState state) {
    _pagingState.pagingController.error =
        state.errorInitialPublicationsFetch ?? 'An unknown error occurred';
  }

  void _handleCompletedState(HomeTreeState state) {
    final items = state.initialPublications;

    if (items.isEmpty) {
      _pagingState.pagingController.appendPage([], 0);
      return;
    }

    _updatePagingControllerItems(state);
  }

  void _updatePagingControllerItems(HomeTreeState state) {
    final items = state.initialPublications;
    final isLastPage = state.initialHasReachedMax;
    final currentPage = state.initialCurrentPage;

    if (isLastPage) {
      _pagingState.pagingController.appendLastPage(items);
    } else {
      _pagingState.pagingController.appendPage(items, currentPage + 1);
    }
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

  Widget _buildMainScreen(HomeTreeState state) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      extendBody: true,
      appBar: _buildAppBar(state),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: AppColors.white,
        elevation: 1,
        strokeWidth: 3,
        displacement: 40,
        edgeOffset: 10,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () {
          context.read<HomeTreeCubit>().fetchVideoFeeds(0);
          return Future.sync(() => _pagingState.pagingController.refresh());
        },
        child: CustomScrollView(
          controller: _scrollState.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildCategories(state)),
            ValueListenableBuilder<bool>(
              valueListenable: _scrollState.isAppBarVisible,
              builder: (context, isVisible, child) => SliverVisibility(
                visible: isVisible,
                maintainState: true, // Keep the state when hidden
                maintainAnimation: true,
                sliver: SliverAppBar(
                  floating: true,
                  snap: false,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 50,
                  flexibleSpace: _buildFiltersBar(state),
                  backgroundColor: AppColors.bgColor,
                ),
              ),
            ),
            if (state.videoPublications.length > 4) _buildContentSection(state),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(HomeTreeState state) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
      sliver: SliverToBoxAdapter(
        child: Container(
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Video Posts",
                      style: TextStyle(
                          color: AppColors.darkBackground,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins"),
                    ),
                  ],
                ),
              ),
              if (state.videoPublications.isNotEmpty) ...[
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: VideoCarousel(
                    items: state.videoPublications.sublist(0, 4),
                  ),
                ),
                SizedBox(height: 8),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: PagedSliverList(
        pagingController: _pagingState.pagingController,
        builderDelegate: PagedChildBuilderDelegate(
          firstPageProgressIndicatorBuilder: (_) => const Progress(),
          newPageProgressIndicatorBuilder: (_) => const Progress(),
          itemBuilder: (context, item, index) {
            final currentItem = item as PublicationPairEntity;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
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

  Widget _buildFiltersBar(HomeTreeState state) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _uiState.selectedFilters,
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
    HomeTreeState state,
    int index,
    Set<int> selectedFilters,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: FilterChip(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        label: Text(
          state.catalogs![index].name,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
          context.goNamed(RoutesByName.subcategories, extra: {
            'category': state.catalogs![index],
            'priceFrom': state.priceFrom,
            'priceTo': state.priceTo,
            'filterState': {
              'bargain': state.bargain,
              'isFree': state.isFree,
              'condition': state.condition,
              'sellerType': state.sellerType,
            },
          });
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
        backgroundColor: AppColors.bgColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 2),
              child: Row(
                children: [
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
                                onPressed: () {
                                  final homeTreeCubit =
                                      BlocProvider.of<HomeTreeCubit>(context);

                                  showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    isScrollControlled: true,
                                    enableDrag: false,
                                    builder: (context) => BlocProvider.value(
                                      value:
                                          homeTreeCubit, // Provide the same cubit instance
                                      child: FiltersPage(page: "initial"),
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
                            width: 38,
                            height: 38,
                            color: AppColors.black,
                          ),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 8,
                          bottom: 12,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Center(
                              child: const Text(
                                "2",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
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

  Widget _buildCategories(HomeTreeState state) {
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          color: AppColors.white,
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Title
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Try Again Button
                FilledButton.icon(
                  onPressed: onTryAgain,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.black,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(color: AppColors.black),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    backgroundColor: Colors.tealAccent,
                    shape: SmoothRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
