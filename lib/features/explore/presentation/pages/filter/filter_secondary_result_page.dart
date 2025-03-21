// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member
// catalog_list_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChildPageUIState {
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

class ChildSearchBarState {
  final isSearching = ValueNotifier<bool>(false);
  final searchText = ValueNotifier<String>('');
  final searchController = SearchController();

  void dispose() {
    isSearching.dispose();
    searchText.dispose();
    searchController.dispose();
  }
}

class ChildScrollState {
  // First, modify the ScrollState class to include a ValueNotifier:

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
    _scrollTimer = Timer(const Duration(milliseconds: 32), () {
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

class ChildPagingState {
  final pagingController =
      PagingController<int, GetPublicationEntity>(firstPageKey: 0);

  void dispose() {
    pagingController.dispose();
  }
}

class FilterSecondaryResultPage extends StatefulWidget {
  const FilterSecondaryResultPage({
    super.key,
  });

  @override
  State<FilterSecondaryResultPage> createState() =>
      _FilterSecondaryResultPageState();
}

class _FilterSecondaryResultPageState extends State<FilterSecondaryResultPage> {
  late final ChildPageUIState _uiState;
  late final ChildSearchBarState _searchState;
  late final ChildScrollState _scrollState;
  late final ChildPagingState _pagingState;

  static const double _videoVisibilityThreshold = 0.9;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _initializeStates();
    _setupListeners();
  }

  void _initializeStates() {
    _uiState = ChildPageUIState();
    _searchState = ChildSearchBarState();
    _scrollState = ChildScrollState();
    _pagingState = ChildPagingState();
  }

  void _setupListeners() {
    _scrollState.setupScrollListener();
    _setupPagingListener();
  }

  void _setupPagingListener() {
    _pagingState.pagingController.addPageRequestListener((pageKey) {
      if (context
              .read<HomeTreeCubit>()
              .state
              .secondaryPublicationsRequestState !=
          RequestState.inProgress) {
        context.read<HomeTreeCubit>().fetchSecondaryPage(pageKey);
      }
    });
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
    return previous.secondaryPublicationsRequestState !=
            current.secondaryPublicationsRequestState ||
        previous.secondaryPublications.length !=
            current.secondaryPublications.length ||
        previous.secondaryHasReachedMax != current.secondaryHasReachedMax;
  }

  void _handleStateChanges(BuildContext context, HomeTreeState state) {
    if (state.filtersTrigered) {
      _pagingState.pagingController.itemList = null;
    }
    if (state.secondaryPublicationsRequestState == RequestState.error) {
      _handleError(state);
    } else if (state.secondaryPublicationsRequestState ==
        RequestState.completed) {
      _handleCompletedState(state);
    }
  }

  void _handleError(HomeTreeState state) {
    _pagingState.pagingController.error =
        state.errorSecondaryPublicationsFetch ??
            AppLocalizations.of(context)!.unknown_error;
  }

  void _handleCompletedState(HomeTreeState state) {
    final items = state.secondaryPublications;

    if (items.isEmpty) {
      _pagingState.pagingController.appendPage([], 0);
      return;
    }

    _updatePagingControllerItems(state);
  }

  void _fetchInitialData() {
    context.read<HomeTreeCubit>().fetchCatalogs();
    context.read<HomeTreeCubit>().fetchLocations();
  }

  void _updatePagingControllerItems(HomeTreeState state) {
    final items = state.secondaryPublications;
    final isLastPage = state.secondaryHasReachedMax;
    final currentPage = state.secondaryCurrentPage;

    if (isLastPage) {
      _pagingState.pagingController.appendLastPage(items);
    } else {
      _pagingState.pagingController.appendPage(items, currentPage + 1);
    }
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: AppColors.white,
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
      backgroundColor: AppColors.white,
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
      backgroundColor: AppColors.white,
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
        onRefresh: () =>
            Future.sync(() => _pagingState.pagingController.refresh()),
        child: CustomScrollView(
          controller: _scrollState.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (state.selectedCatalog != null)
              SliverAppBar(
                floating: false,
                snap: false,
                pinned: true,
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

  Widget _buildFiltersBar(HomeTreeState state) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _uiState.selectedFilters,
      builder: (context, selectedFilters, _) {
        return Container(
          color: AppColors.white,
          height: 46,
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

  Widget _buildFilterChip(
    HomeTreeState state,
    int index,
    Set<int> selectedFilters,
  ) {
    return BlocSelector<LanguageBloc, LanguageState, String>(
      selector: (state) =>
          state is LanguageLoaded ? state.languageCode : AppLanguages.english,
      builder: (context, languageCode) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: FilterChip(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            label: Text(
              getLocalizedText(
                state.selectedCatalog!.childCategories[index].name,
                state.selectedCatalog!.childCategories[index].nameUz,
                state.selectedCatalog!.childCategories[index].nameRu,
                languageCode,
              ),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            selected: selectedFilters.contains(index),
            backgroundColor: AppColors.containerColor,
            selectedColor: AppColors.green,
            labelStyle: TextStyle(
              color: selectedFilters.contains(index)
                  ? AppColors.white
                  : AppColors.black,
            ),
            onSelected: (selected) {
              context.read<HomeTreeCubit>().selectChildCategory(
                  state.selectedCatalog!.childCategories[index]);
              context.goNamed(RoutesByName.attributes, extra: {
                'category': state.selectedCatalog,
                'childCategory': state.selectedCatalog?.childCategories[index],
                'filterState': {
                  'bargain': state.bargain,
                  'isFree': state.isFree,
                  'condition': state.condition,
                  'sellerType': state.sellerType,
                  'country': state.selectedCountry,
                  'state': state.selectedState,
                  'county': state.selectedCounty,
                },
              });
            },
            side: BorderSide(width: 1, color: AppColors.transparent),
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
                                'country': state.selectedCountry,
                                'state': state.selectedState,
                                'county': state.selectedCounty,
                              },
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    AppLocalizations.of(context)!
                                        .whatAreYouLookingFor, // Show current search text or default
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.black,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          builder: (context) => BlocProvider.value(
                            value:
                                homeTreeCubit, // Provide the same cubit instance
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: FractionallySizedBox(
                                heightFactor: 1,
                                child: FiltersPage(
                                  page: "ssssss",
                                ),
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
}
