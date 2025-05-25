// catalog_list_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_provider.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/boosted_card.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/product_card_container.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/top_app_recomendation.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/video/presentation/wigets/scrollable_list.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
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
      PagingController<int, GetPublicationEntity>(firstPageKey: 0);

  void dispose() {
    pagingController.dispose();
  }
}

class InitialHomeTreePage extends StatefulWidget {
  const InitialHomeTreePage({
    super.key,
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
    _fetchGlobalData();
    _fetchInitialData();
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

  void _fetchGlobalData() {
    // Dispatch events to fetch user id and image
    context.read<GlobalBloc>().add(FetchUserIdEvent());
    context.read<GlobalBloc>().add(FetchUserImageEvent());
  }

  void _fetchInitialData() {
    context.read<UserProfileBloc>().add(GetUserData());

    // Move the userId check to be asynchronous
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<GlobalBloc>().userId;
      if (userId != null) {
        context.read<ChatProvider>().initializeChat(userId);
      }
    });

    context.read<HomeTreeCubit>().fetchCatalogs();
    context.read<HomeTreeCubit>().fetchLocations();
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
    _pagingState.pagingController.error = state.errorInitialPublicationsFetch ??
        AppLocalizations.of(context)!.unknown_error;
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: _buildAppBar(state),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Theme.of(context).cardColor,
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
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 28,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalizations.of(context)!.video_posts,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: Constants.Arial,
                    ),
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
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      sliver: PagedSliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 1.5,
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
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: state.catalogs?.length,
          itemBuilder: (context, index) =>
              _buildFilterChip(state, index, selectedFilters),
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
                state.catalogs?[index].name,
                state.catalogs?[index].nameUz,
                state.catalogs?[index].nameRu,
                languageCode,
              ),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            selected: selectedFilters.contains(index),
            backgroundColor: Theme.of(context).cardColor,
            selectedColor: AppColors.black,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            onSelected: (selected) {
              context
                  .read<HomeTreeCubit>()
                  .selectCatalog(state.catalogs![index]);
              context.goNamed(RoutesByName.subcategories, extra: {
                'category': state.catalogs![index],
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
              });
            },
            side: BorderSide(width: 1, color: Theme.of(context).cardColor),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            color: Theme.of(context).colorScheme.onSecondary,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  AppLocalizations.of(context)!
                                      .whatAreYouLookingFor,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              VerticalDivider(
                                color: Theme.of(context).highlightColor,
                                width: 1,
                                indent: 12,
                                endIndent: 12,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              IconButton(
                                color: Theme.of(context).iconTheme.color,
                                icon: Image.asset(
                                  AppIcons.filterIc,
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(context).iconTheme.color,
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
                  const SizedBox(width: 6),
                  Transform.translate(
                    offset: Offset(0, 3),
                    child: IconButton(
                      icon: Icon(CupertinoIcons.hammer),
                      onPressed: () async {
                        _showChatNotAvailableMessage(context);
                      },
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

  void _showChatNotAvailableMessage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.hammer,
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.surpriseComingSoon,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: Constants.Arial,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.surpriseInDevelopmentMessage,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: Constants.Arial,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.gotIt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: Constants.Arial,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        title: AppLocalizations.of(context)!.recent,
        icon: Icons.access_time_rounded,
        color: Colors.blue,
      ),
      RecommendationItem(
        title: AppLocalizations.of(context)!.season_fashion,
        icon: Icons.checkroom_rounded,
        color: Colors.purple,
      ),
      RecommendationItem(
        title: AppLocalizations.of(context)!.for_free,
        icon: Icons.card_giftcard_rounded,
        color: Colors.red,
      ),
      RecommendationItem(
        title: AppLocalizations.of(context)!.gift_ideas,
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
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.7,
            ),
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
                  AppLocalizations.of(context)!.oops_something_went_wrong,
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
                  label: Text(
                    AppLocalizations.of(context)!.try_again,
                    style: TextStyle(color: AppColors.black),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    backgroundColor: CupertinoColors.systemGreen,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 14,
                        cornerSmoothing: 0.7,
                      ),
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
