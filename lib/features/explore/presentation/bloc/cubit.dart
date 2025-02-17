// post_cubit.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/usecase/get_filtered_publications_values_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_prediction_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_video_publications_usecase.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/global/global_bloc.dart';

class HomeTreeCubit extends Cubit<HomeTreeState> {
  final GetGategoriesUsecase getCatalogsUseCase;
  final GetPublicationsUsecase getPublicationsUseCase;
  final GetPredictionsUseCase getPredictionsUseCase;
  final GetVideoPublicationsUsecase getVideoPublicationsUsecase;
  final GetFilteredPublicationsValuesUsecase
      getFilteredPublicationsValuesUsecase;
  final GlobalBloc globalBloc;
  static const int pageSize = 20;
  Timer? _debounceTimer;
  Timer? _filterPredictionDebounceTimer;
  CancelToken? _filterPredictionCancelToken;
  HomeTreeCubit({
    required this.getCatalogsUseCase,
    required this.getPublicationsUseCase,
    required this.getPredictionsUseCase,
    required this.getVideoPublicationsUsecase,
    required this.getFilteredPublicationsValuesUsecase,
    required this.globalBloc,
  }) : super(HomeTreeState());

  void _syncFollowStatusesForPublications(
      List<GetPublicationEntity> publications) {
    final Map<String, bool> userFollowStatuses = {};
    final Map<String, int> userFollowersCount = {};
    final Map<String, int> userFollowingCount = {};
    

    for (var publication in publications) {
      final seller = publication.seller;
      userFollowStatuses[seller.id] = seller.isFollowing;
      userFollowersCount[seller.id] = seller.followers;
      userFollowingCount[seller.id] = seller.followings;
    }

    globalBloc.add(SyncFollowStatusesEvent(
      userFollowStatuses: userFollowStatuses,
      userFollowersCount: userFollowersCount,
      userFollowingCount: userFollowingCount,
    ));
  }

  void _syncFollowStatuses(List<PublicationPairEntity> publications) {
    final Map<String, bool> newFollowStatuses = {};
    final Map<String, int> newFollowersCount = {};
    final Map<String, int> newFollowingCount = {};

    for (var pair in publications) {
      // Process first publication's seller
      final firstSeller = pair.firstPublication.seller;
      newFollowStatuses[firstSeller.id] = firstSeller.isFollowing;
      newFollowersCount[firstSeller.id] = firstSeller.followers;
      newFollowingCount[firstSeller.id] = firstSeller.followings;

      if (pair.secondPublication != null) {
        final secondSeller = pair.secondPublication!.seller;
        newFollowStatuses[secondSeller.id] = secondSeller.isFollowing;
        newFollowersCount[secondSeller.id] = secondSeller.followers;
        newFollowingCount[secondSeller.id] = secondSeller.followings;
      }
    }

    globalBloc.add(SyncFollowStatusesEvent(
      userFollowStatuses: newFollowStatuses,
      userFollowersCount: newFollowersCount,
      userFollowingCount: newFollowingCount,
    ));
  }

  void _syncLikeStatusesForPublications(
      List<GetPublicationEntity> publications) {
    final Map<String, bool> publicationLikeStatuses = {};

    for (var publication in publications) {
      publicationLikeStatuses[publication.id] = publication.isLiked;
    }

    globalBloc.add(SyncLikeStatusesEvent(
      publicationLikeStatuses: publicationLikeStatuses,
    ));
  }

  void _syncLikeStatuses(List<PublicationPairEntity> publications) {
    // Create a map for new like statuses
    final Map<String, bool> newLikeStatuses = {};

    // Process all publications
    for (var pair in publications) {
      // Add first publication's like status
      newLikeStatuses[pair.firstPublication.id] = pair.firstPublication.isLiked;

      // Add second publication's like status if it exists
      if (pair.secondPublication != null) {
        newLikeStatuses[pair.secondPublication!.id] =
            pair.secondPublication!.isLiked;
      }
    }

    // Send the new statuses to be merged with existing ones
    globalBloc.add(SyncLikeStatusesEvent(
      publicationLikeStatuses: newLikeStatuses,
    ));
  }

  Future<void> getPredictions() async {
    // Cancel any previous timer
    _debounceTimer?.cancel();

    final query = state.searchText;

    if (query == null || query.isEmpty) {
      emit(state.copyWith(
        predictions: [],
        predictionsRequestState: RequestState.completed,
      ));
      return;
    }

    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
      emit(state.copyWith(
        predictionsRequestState: RequestState.inProgress,
      ));

      final result = await getPredictionsUseCase(
        params: GetPredictionParams(query: query),
      );

      result.fold(
        (failure) => emit(state.copyWith(
          predictionsRequestState: RequestState.error,
          errorPredictionsFetch: _mapFailureToMessage(failure),
        )),
        (predictions) => emit(state.copyWith(
          predictions: predictions,
          predictionsRequestState: RequestState.completed,
        )),
      );
    });
  }

  Future<void> handlePredictionSelection(
    PredictionEntity prediction,
    BuildContext context,
  ) async {
    CategoryModel? selectedCategory;
    ChildCategoryModel? selectedChildCategory;

    // If we have a category ID, find the category
    if (prediction.parentCategoryId != null && state.catalogs != null) {
      selectedCategory = state.catalogs!.firstWhere(
        (category) => category.id == prediction.parentCategoryId,
        orElse: () => throw Exception('Category not found'),
      );

      // If we have a child category ID, find it within the selected category
      if (prediction.categoryId != null) {
        selectedChildCategory = selectedCategory.childCategories.firstWhere(
          (child) => child.id == prediction.categoryId,
          orElse: () => throw Exception('Child category not found'),
        );
      }
    }

    // Navigate based on what was found, passing necessary data
    if (selectedChildCategory != null && selectedCategory != null) {
      // Prepare the extra data map with all prediction data
      final Map<String, dynamic> extraData = {
        'category': selectedCategory,
        'childCategory': selectedChildCategory,
        'parentAttributeKeyId': prediction.parentAttributeKeyId,
        'parentAttributeValueId': prediction.parentAttributeValueId,
        'childAttributeKeyId': prediction.childAttributeKeyId,
        'childAttributeValueId': prediction.childAttributeValueId,
      };
      context.pushReplacementNamed(RoutesByName.attributes, extra: extraData);
    }
  }

  void handleVideoFeedNavigation(BuildContext context, int selectedIndex) {
    if (state.videoPublications.isNotEmpty) {
      final limitedVideos = state.videoPublications.length > 10
          ? state.videoPublications.sublist(0, 10)
          : state.videoPublications;

      if (state.videoPublications.length > 10) {
        emit(state.copyWith(videoPublications: limitedVideos));
      }

      context.push(Routes.videosFeed, extra: {
        'videos': limitedVideos,
        'video_current_page': state.videoCurrentPage,
        'index': selectedIndex,
      });
    }
  }

  void selectAttributeById(String attributeKeyId, String attributeValueId) {
    // Search for attribute by checking values in both current and dynamic attributes
    AttributeModel? attribute;

    // Helper function to find attribute by checking values
    AttributeModel? findAttribute(List<AttributeModel> attributes) {
      for (var attr in attributes) {
        for (var value in attr.values) {
          if (value.attributeValueId == attributeValueId) {
            return attr;
          }
        }
      }
      return null;
    }

    // First try current attributes
    attribute = findAttribute(state.selectedChildCategory!.attributes);
    debugPrint(state.currentAttributes.length.toString());
    debugPrint("😤😤😤 ${attribute?.attributeKey}");

    attribute ??= findAttribute(state.dynamicAttributes);

    if (attribute == null) {
      throw Exception('Attribute not found for keyId: $attributeKeyId');
    }

    // Find the value in the attribute's values
    final value = attribute.values.firstWhere(
      (val) => val.attributeValueId == attributeValueId,
      orElse: () => throw Exception('Value not found: $attributeValueId'),
    );

    final Map<String, dynamic> newSelectedValues =
        Map<String, dynamic>.from(state.selectedValues);
    final Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map<AttributeModel, AttributeValueModel>.from(
            state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List<AttributeModel>.from(state.dynamicAttributes);

    if (attribute.filterWidgetType == 'oneSelectable') {
      final currentValue = newSelectedValues[attribute.attributeKey];
      if (currentValue?.attributeValueId == attributeValueId) return;

      // Clear child-related data when parent value changes
      if (attribute.subFilterWidgetType != 'null') {
        final childKey = '${attribute.attributeKey}_child';
        newSelectedValues.remove(childKey);
        newSelectedAttributeValues
            .removeWhere((attr, _) => attr.attributeKey == childKey);

        // Update dynamic attributes
        _handleDynamicAttributeCreation(
          attribute,
          value,
          newDynamicAttributes,
        );
      }

      // Update the parent attribute's value
      newSelectedValues[attribute.attributeKey] = value;
      newSelectedAttributeValues[attribute] = value;
    } else {
      // Handle multi-select case
      newSelectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValueModel>[]);
      final list = newSelectedValues[attribute.attributeKey]
          as List<AttributeValueModel>;

      final existingValue = list.firstWhere(
        (v) => v.attributeValueId == attributeValueId,
        orElse: () => value,
      );

      if (list.contains(existingValue)) {
        list.remove(existingValue);
      } else {
        list.add(value);
      }
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));

    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
    }
  }

  void updateSearchText(String? text) {
    // Cancel any previous timer
    _debounceTimer?.cancel();

    emit(state.copyWith(
      searchText: text,
      searchPublicationsRequestState: RequestState.idle,
    ));
  }

  void resetRequestState() {
    emit(state.copyWith(
      childPublicationsRequestState: RequestState.idle,
      errorChildPublicationsFetch: null,
    ));
  }

  void clearSearchText() {
    // Log before state change
    debugPrint("Before clear: 😆😆😆😆${state.searchText}");

    // Use bloc observer or add a delay to properly see state changes
    emit(state.copyWith(
      searchText: '', // Make sure null is handled in your copyWith method
      searchPublications: [],
      searchPublicationsRequestState: RequestState.idle,
      searchCurrentPage: 0,
      searchHasReachedMax: false,
      errorSearchPublicationsFetch: null,
    ));

    // Add this to see the state change in the next frame
    Future.microtask(() {
      debugPrint("After clear: 😆😆😆😆${state.searchText}");
    });
  }

  void clearPrediction() {
    emit(state.copyWith(
      predictions: [],
      predictionsRequestState: RequestState.idle,
    ));
  }

  Future<void> searchPage(int pageKey) async {
    if (state.searchPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate publications request for page: $pageKey');
      return;
    }
    debugPrint('🔍 Fetching page: $pageKey with search: ${state.searchText}');

    if (pageKey == 0) {
      emit(state.copyWith(
        searchPublicationsRequestState: RequestState.inProgress,
        errorSearchPublicationsFetch: null,
        searchPublications: [],
        searchHasReachedMax: false,
        searchCurrentPage: 0,
      ));
    } else {
      emit(state.copyWith(
        searchPublicationsRequestState: RequestState.inProgress,
        errorSearchPublicationsFetch: null,
      ));
    }

    try {
      bool shouldIncludeFilter(dynamic value, dynamic defaultValue) {
        return value != null && value != defaultValue;
      }

      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          // Only include bargain if true
          sellerType:
              state.sellerType == SellerType.ALL ? null : state.sellerType.name,
          isFree: state.isFree == true ? true : null,
          bargain: state.bargain == true ? true : null,
          condition: shouldIncludeFilter(state.condition, 'ALL')
              ? state.condition
              : null,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          // Include category IDs if selected
          categoryId: state.selectedCatalog?.id,
          subcategoryId: state.selectedChildCategory?.id,
          // Include filters if they exist
          filters: state.generateFilterParameters().isNotEmpty
              ? state.generateFilterParameters()
              : null,
          // Include numerics if they exist
          numerics: state._generateNumericFilters().isNotEmpty
              ? state._generateNumericFilters()
              : null,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            searchPublicationsRequestState: RequestState.error,
            errorSearchPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (paginatedData) {
          // Determine isLast by checking the last item's isLast property
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;

          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;
          _syncFollowStatuses(updatedPublications);
          _syncLikeStatuses(updatedPublications);
          emit(
            state.copyWith(
              searchPublicationsRequestState: RequestState.completed,
              errorSearchPublicationsFetch: null,
              searchPublications: updatedPublications,
              searchHasReachedMax: isLastPage,
              searchCurrentPage: pageKey,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        searchPublicationsRequestState: RequestState.error,
        errorSearchPublicationsFetch: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> handleSearch(String? searchText) async {
    // Cancel any previous timer
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
      if (searchText == null || searchText.isEmpty) return;

      emit(state.copyWith(
        searchPublicationsRequestState: RequestState.inProgress,
        searchText: searchText.isEmpty ? null : searchText,
        searchPublications: [],
        searchCurrentPage: 0,
        searchHasReachedMax: false,
        errorSearchPublicationsFetch: null,
      ));

      try {
        await searchPage(0);
        emit(state.copyWith(
            searchPublicationsRequestState: RequestState.completed));
      } catch (e) {
        emit(
            state.copyWith(searchPublicationsRequestState: RequestState.error));
        rethrow;
      }
    });
  }

  Future<void> fetchInitialPage(int pageKey) async {
    if (state.initialPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate publications request for page: $pageKey');
      return;
    }

    debugPrint('🔍 Fetching page: $pageKey with search: ${state.searchText}');

    if (pageKey == 0) {
      emit(state.copyWith(
        initialPublicationsRequestState: RequestState.inProgress,
        errorInitialPublicationsFetch: null,
        initialPublications: [],
        initialHasReachedMax: false,
        initialCurrentPage: 0,
      ));
    } else {
      emit(state.copyWith(
        initialPublicationsRequestState: RequestState.inProgress,
        errorInitialPublicationsFetch: null,
      ));
    }

    try {
      bool shouldIncludeFilter(dynamic value, dynamic defaultValue) {
        return value != null && value != defaultValue;
      }

      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          bargain: state.bargain == true ? true : null,
          condition: shouldIncludeFilter(state.condition, 'ALL')
              ? state.condition
              : null,
          sellerType:
              state.sellerType == SellerType.ALL ? null : state.sellerType.name,
          isFree: state.isFree == true ? true : null,
        ),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              initialPublicationsRequestState: RequestState.error,
              errorInitialPublicationsFetch: _mapFailureToMessage(failure),
              filtersTrigered: false,
            ),
          );
        },
        (paginatedData) {
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;
          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;

          // Sync follow statuses
          _syncFollowStatuses(updatedPublications);
          _syncLikeStatuses(updatedPublications);

          emit(
            state.copyWith(
              initialPublicationsRequestState: RequestState.completed,
              errorInitialPublicationsFetch: null,
              initialPublications: updatedPublications,
              initialHasReachedMax: isLastPage,
              initialCurrentPage: pageKey,
              filtersTrigered: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        initialPublicationsRequestState: RequestState.error,
        errorInitialPublicationsFetch: 'An unexpected error occurred',
        filtersTrigered: false,
      ));
    }
  }

  Future<void> fetchSecondaryPage(int pageKey) async {
    if (state.secondaryPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate publications request for page: $pageKey');
      return;
    }
    debugPrint('🔍 Fetching page: $pageKey with search: ${state.searchText}');

    if (pageKey == 0) {
      emit(state.copyWith(
        secondaryPublicationsRequestState: RequestState.inProgress,
        errorSecondaryPublicationsFetch: null,
        secondaryPublications: [],
        secondaryHasReachedMax: false,
        secondaryCurrentPage: 0,
      ));
    } else {
      emit(state.copyWith(
        secondaryPublicationsRequestState: RequestState.inProgress,
        errorSecondaryPublicationsFetch: null,
      ));
    }

    try {
      debugPrint("🐁🐁${state.selectedCatalog}");
      debugPrint("🐁🐁${state.selectedCatalog?.id}");
      bool shouldIncludeFilter(dynamic value, dynamic defaultValue) {
        return value != null && value != defaultValue;
      }

      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          bargain: state.bargain == true ? true : null,
          sellerType:
              state.sellerType == SellerType.ALL ? null : state.sellerType.name,
          isFree: state.isFree == true ? true : null,
          condition: shouldIncludeFilter(state.condition, 'ALL')
              ? state.condition
              : null,
          categoryId: state.selectedCatalog?.id,
        ),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              secondaryPublicationsRequestState: RequestState.error,
              errorSecondaryPublicationsFetch: _mapFailureToMessage(failure),
              filtersTrigered: false,
            ),
          );
        },
        (paginatedData) {
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;

          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;
          _syncFollowStatuses(updatedPublications);
          _syncLikeStatuses(updatedPublications);
          emit(
            state.copyWith(
              secondaryPublicationsRequestState: RequestState.completed,
              errorSecondaryPublicationsFetch: null,
              secondaryPublications: updatedPublications,
              secondaryHasReachedMax: isLastPage,
              secondaryCurrentPage: pageKey,
              filtersTrigered: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        secondaryPublicationsRequestState: RequestState.error,
        errorSecondaryPublicationsFetch: 'An unexpected error occurred',
        filtersTrigered: false,
      ));
    }
  }

  Future<void> fetchChildPage(int pageKey) async {
    if (state.childPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate publications request for page: $pageKey');
      return;
    }

    if (pageKey == 0) {
      emit(state.copyWith(
        childPublicationsRequestState: RequestState.inProgress,
        childPublications: [],
        childHasReachedMax: false,
        childCurrentPage: 0,
        errorChildPublicationsFetch: null,
      ));
    } else {
      emit(state.copyWith(
        childPublicationsRequestState: RequestState.inProgress,
        errorChildPublicationsFetch: null,
      ));
    }

    try {
      // Helper function to determine if a filter value should be included
      bool shouldIncludeFilter(dynamic value, dynamic defaultValue) {
        return value != null && value != defaultValue;
      }

      // Create GetPublicationsParams with conditional parameters
      final params = GetPublicationsParams(
        page: pageKey,
        size: pageSize,
        // Only include bargain if true
        sellerType:
            state.sellerType == SellerType.ALL ? null : state.sellerType.name,
        isFree: state.isFree == true ? true : null,
        bargain: state.bargain == true ? true : null,
        condition: shouldIncludeFilter(state.condition, 'ALL')
            ? state.condition
            : null,
        priceFrom: state.priceFrom,
        priceTo: state.priceTo,
        // Include category IDs if selected
        categoryId: state.selectedCatalog?.id,
        subcategoryId: state.selectedChildCategory?.id,
        // Include filters if they exist
        filters: state.generateFilterParameters().isNotEmpty
            ? state.generateFilterParameters()
            : null,
        // Include numerics if they exist
        numerics: state._generateNumericFilters().isNotEmpty
            ? state._generateNumericFilters()
            : null,
      );

      final result = await getPublicationsUseCase(params: params);

      result.fold(
        (failure) {
          emit(state.copyWith(
            childPublicationsRequestState: RequestState.error,
            errorChildPublicationsFetch: _mapFailureToMessage(failure),
            filtersTrigered: false,
          ));
        },
        (paginatedData) {
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;
          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;
          _syncFollowStatuses(updatedPublications);
          _syncLikeStatuses(updatedPublications);
          emit(state.copyWith(
            childPublicationsRequestState: RequestState.completed,
            childPublications: updatedPublications,
            childHasReachedMax: isLastPage,
            childCurrentPage: pageKey,
            errorChildPublicationsFetch: null,
            filtersTrigered: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        childPublicationsRequestState: RequestState.error,
        errorChildPublicationsFetch: 'An unexpected error occurred',
        filtersTrigered: false,
      ));
    }
  }

  Future<void> fetchFilteredPredictionValues() async {
    // Cancel any existing timer
    _filterPredictionDebounceTimer?.cancel();

    // Cancel any ongoing request
    if (_filterPredictionCancelToken != null) {
      _filterPredictionCancelToken!.cancel('Cancelled due to new request');
      _filterPredictionCancelToken = null;
    }

    // Create new debounce timer
    _filterPredictionDebounceTimer =
        Timer(const Duration(milliseconds: 1), () async {
      emit(state.copyWith(
        filteredValuesRequestState: RequestState.inProgress,
        errorFilteredValuesFetch: null,
      ));

      try {
        bool shouldIncludeFilter(dynamic value, dynamic defaultValue) {
          return value != null && value != defaultValue;
        }

        // Create new cancel token for this request
        _filterPredictionCancelToken = CancelToken();
        debugPrint("🤩🤩${state.searchText}");
        final params = GetFilteredPublicationsValuesParams(
          query: state.searchText,
          categoryId: state.selectedCatalog?.id,
          subcategoryId: state.selectedChildCategory?.id,
          sellerType:
              state.sellerType == SellerType.ALL ? null : state.sellerType.name,
          isFree: state.isFree == true ? true : null,
          bargain: state.bargain == true ? true : null,
          condition: shouldIncludeFilter(state.condition, 'ALL')
              ? state.condition
              : null,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          filters: state.generateFilterParameters().isNotEmpty
              ? state.generateFilterParameters()
              : null,
          numerics: state._generateNumericFilters().isNotEmpty
              ? state._generateNumericFilters()
              : null,
          cancelToken:
              _filterPredictionCancelToken, // Pass cancel token to the usecase
        );

        final result =
            await getFilteredPublicationsValuesUsecase(params: params);

        // Check if request was cancelled
        if (_filterPredictionCancelToken?.isCancelled ?? false) {
          return;
        }

        result.fold(
          (failure) {
            // Only emit if the failure is not due to cancellation
            if (failure is! CancellationFailure) {
              emit(state.copyWith(
                filteredValuesRequestState: RequestState.error,
                errorFilteredValuesFetch: _mapFailureToMessage(failure),
                predictedPriceFrom: 0,
                predictedPriceTo: 0,
                predictedFoundPublications: 0,
                filtersTrigered: false,
              ));
            }
          },
          (filterPrediction) {
            emit(state.copyWith(
              filteredValuesRequestState: RequestState.completed,
              predictedPriceFrom: filterPrediction.priceFrom,
              predictedPriceTo: filterPrediction.priceTo,
              predictedFoundPublications: filterPrediction.foundPublications,
              errorFilteredValuesFetch: null,
              filtersTrigered: false,
            ));
          },
        );
      } catch (e) {
        if (e is! CancelledException) {
          emit(state.copyWith(
            filteredValuesRequestState: RequestState.error,
            errorFilteredValuesFetch: 'An unexpected error occurred',
            predictedPriceFrom: 0,
            predictedPriceTo: 0,
            predictedFoundPublications: 0,
            filtersTrigered: false,
          ));
        }
      } finally {
        // Clear cancel token after request completes or fails
        _filterPredictionCancelToken = null;
      }
    });
  }

  void filtersTrigered() {
    emit(state.copyWith(
      filtersTrigered: true,
    ));
  }

// Update the related state management methods
  void updateSellerType(SellerType type, bool filter, String page) {
    emit(state.copyWith(
      sellerType: type,
      filtersTrigered: true,
    ));
    if (filter) {
      fetchFilteredPredictionValues();
    } else {
      if (page == 'CHILD') {
        fetchChildPage(0);
      }
      if (page == "SEARCH_RESULT") {
        searchPage(0);
      }
    }
  }

  void updateCondition(
    String condition,
    bool filter,
    String page,
  ) {
    emit(state.copyWith(
      condition: condition,
      filtersTrigered: true,
    ));
    if (filter) {
      fetchFilteredPredictionValues();
    } else {
      if (page == 'CHILD') {
        fetchChildPage(0);
      }
      if (page == "SEARCH_RESULT") {
        searchPage(0);
      }
    }
  }

  void toggleBargain(
    bool value,
    bool filter,
    String page,
  ) {
    emit(state.copyWith(
      bargain: value,
      filtersTrigered: true,
    ));
    if (filter) {
      fetchFilteredPredictionValues();
    } else {
      if (page == 'CHILD') {
        fetchChildPage(0);
      }
      if (page == "SEARCH_RESULT") {
        searchPage(0);
      }
    }
  }

  void toggleIsFree(
    bool value,
    bool filter,
    String page,
  ) {
    emit(state.copyWith(
      isFree: value,
      filtersTrigered: true,
    ));
    if (filter) {
      fetchFilteredPredictionValues();
    } else {
      if (page == 'CHILD') {
        fetchChildPage(0);
      }
      if (page == "SEARCH_RESULT") {
        searchPage(0);
      }
    }
  }

  Future<void> fetchVideoFeeds(int pageKey) async {
    if (state.videoPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate video publications request for page: $pageKey');
      return;
    }

    debugPrint(
        '🔍 Fetching video page: $pageKey with search: ${state.searchText}');

    if (pageKey == 0) {
      emit(state.copyWith(
        videoPublicationsRequestState: RequestState.inProgress,
        errorVideoPublicationsFetch: null,
        videoPublications: [],
        videoHasReachedMax: false,
        videoCurrentPage: 0,
      ));
    } else {
      emit(state.copyWith(
        videoPublicationsRequestState: RequestState.inProgress,
        errorVideoPublicationsFetch: null,
      ));
    }

    try {
      debugPrint("🐁🐁${state.selectedCatalog}");
      debugPrint("🐁🐁${state.selectedCatalog?.id}");

      final result = await getVideoPublicationsUsecase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: 10,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          categoryId: state.selectedCatalog?.id,
        ),
      );

      result.fold(
        (failure) {
          debugPrint("🐁🐁FAAAAAAAAAAAAAILLLL");
          debugPrint("🐁🐁🐁🐁FAAAAAAAAAAAAAILLLL");

          emit(state.copyWith(
            videoPublicationsRequestState: RequestState.error,
            errorVideoPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (videoPublicationsEntity) {
          final updatedPublications = pageKey == 0
              ? videoPublicationsEntity.content
              : videoPublicationsEntity.content;
          _syncFollowStatusesForPublications(updatedPublications);
          _syncLikeStatusesForPublications(updatedPublications);
          emit(
            state.copyWith(
              videoPublicationsRequestState: RequestState.completed,
              errorVideoPublicationsFetch: null,
              videoPublications: updatedPublications,
              videoHasReachedMax: videoPublicationsEntity.isLast,
              videoCurrentPage: videoPublicationsEntity.number,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("🐁🐁FAAAAAAAAAAAAAILLLL REASON : $e");
      emit(state.copyWith(
        videoPublicationsRequestState: RequestState.error,
        errorVideoPublicationsFetch: 'An unexpected error occurred',
      ));
    }
  }

  void setPriceRange(
    double? from,
    double? to,
    String page,
  ) {
    emit(state.copyWith(
      priceFrom: from,
      priceTo: to,
      filtersTrigered: true,
    ));
    if (state.searchText != null) {
      searchPage(0);
    } else {
      if (page == 'CHILD') {
        fetchChildPage(0);
      }
      if (page == "SEARCH_RESULT") {
        searchPage(0);
      }
    }
  }

  void clearVideos() {
    emit(HomeTreeState(
      videoPublications: [],
      videoPublicationsRequestState: RequestState.idle,
      videoHasReachedMax: false,
      videoCurrentPage: 0,
      errorVideoPublicationsFetch: null,
    ));
  }

  void clearPriceRange() {
    emit(state.copyWith(
      priceFrom: null,
      priceTo: null,
      filtersTrigered: true,
    ));

    fetchChildPage(0);
  }

  void getAtributesForPost() {
    final List<AttributeRequestValue> attributeRequests = [];
    final Set<String> processedCombinations = {};

    // Handle single-selection attributes
    for (var entry in state.selectedAttributeValues.entries) {
      AttributeModel attribute = entry.key;
      AttributeValueModel value = entry.value;

      String combinationKey =
          '${value.attributeKeyId}_${value.attributeValueId}';

      if (!processedCombinations.contains(combinationKey)) {
        processedCombinations.add(combinationKey);

        if (value.attributeKeyId.isNotEmpty &&
            value.attributeValueId.isNotEmpty) {
          attributeRequests.add(AttributeRequestValue(
            attributeId: value.attributeKeyId,
            attributeValueIds: [value.attributeValueId],
          ));

          // If this value has a list (sub-values) and they are actually selected
          if (value.list.isNotEmpty) {
            // Find the corresponding child attribute in dynamicAttributes
            final childAttribute = state.dynamicAttributes.firstWhere(
              (attr) => attr.attributeKey == '${attribute.attributeKey}_child',
              orElse: () => attribute,
            );

            final childValue = state.selectedAttributeValues[childAttribute];
            if (childValue != null) {
              String childCombinationKey =
                  '${childValue.attributeKeyId}_${childValue.attributeValueId}';

              if (!processedCombinations.contains(childCombinationKey) &&
                  childValue.attributeKeyId.isNotEmpty &&
                  childValue.attributeValueId.isNotEmpty) {
                processedCombinations.add(childCombinationKey);
                attributeRequests.add(AttributeRequestValue(
                  attributeId: childValue.attributeKeyId,
                  attributeValueIds: [childValue.attributeValueId],
                ));
              }
            }
          }
        }
      }
    }

    // Handle multi-selection attributes
    for (var entry in state.selectedValues.entries) {
      if (entry.value is List<AttributeValueModel>) {
        List<AttributeValueModel> values =
            entry.value as List<AttributeValueModel>;
        if (values.isNotEmpty) {
          String attributeId = values.first.attributeKeyId;
          List<String> valueIds =
              values.map((v) => v.attributeValueId).toList();

          if (attributeId.isNotEmpty && valueIds.isNotEmpty) {
            attributeRequests.add(AttributeRequestValue(
              attributeId: attributeId,
              attributeValueIds: valueIds,
            ));

            // Handle child attributes for multi-select
            for (var value in values) {
              if (value.list.isNotEmpty) {
                final childKey = '${entry.key}_child';
                final childValues = state.selectedValues[childKey];

                if (childValues is List<AttributeValueModel> &&
                    childValues.isNotEmpty) {
                  String childAttributeId = childValues.first.attributeKeyId;
                  List<String> childValueIds =
                      childValues.map((v) => v.attributeValueId).toList();

                  if (childAttributeId.isNotEmpty && childValueIds.isNotEmpty) {
                    attributeRequests.add(AttributeRequestValue(
                      attributeId: childAttributeId,
                      attributeValueIds: childValueIds,
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    emit(state.copyWith(attributeRequests: attributeRequests));

    // Debug print
    debugPrint("Attribute requests:");
    for (var request in attributeRequests) {
      debugPrint("Attribute ID: ${request.attributeId}");

      debugPrint(
          "Attribute Value IDs: ${request.attributeValueIds.join(', ')}");
      debugPrint("------------");
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> fetchCatalogs() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await getCatalogsUseCase(params: NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        error: _mapFailureToMessage(failure),
        catalogs: null,
        isLoading: false,
      )),
      (catalogs) => emit(state.copyWith(
        catalogs: catalogs,
        error: null,
        isLoading: false,
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Network connection error';
      default:
        return 'Unexpected error';
    }
  }

  void selectCatalog(CategoryModel catalog) {
    final List<CategoryModel> catalogHistory = List.from(state.catalogHistory);

    // Always add current catalog to history before changing
    if (state.selectedCatalog != null &&
        !catalogHistory.contains(state.selectedCatalog)) {
      catalogHistory.add(state.selectedCatalog!);
    }

    // Always clear previous selections when selecting a catalog
    emit(state.copyWith(
      selectedCatalog: catalog,
      selectedChildCategory: null,
      currentAttributes: [],
      dynamicAttributes: [],
      selectedValues: {},
      catalogHistory: catalogHistory,
      childCategorySelections: {}, // Clear all child category selections
      childCategoryDynamicAttributes: {}, // Clear all dynamic attributes
      selectedAttributeValues: {}, // Clear selected attribute values
      attributeOptionsVisibility: {}, // Reset visibility states
    ));
  }

  void selectChildCategory(ChildCategoryModel childCategory) {
    final List<ChildCategoryModel> childCategoryHistory =
        List.from(state.childCategoryHistory);

    // Always add current child category to history before changing
    if (state.selectedChildCategory != null &&
        !childCategoryHistory.contains(state.selectedChildCategory)) {
      childCategoryHistory.add(state.selectedChildCategory!);
    }

    // Always clear previous selections when selecting a child category
    emit(state.copyWith(
      selectedCatalog: state.selectedCatalog,
      selectedChildCategory: childCategory,
      currentAttributes: childCategory.attributes,
      numericFields: childCategory.numericFields,
      numericFieldValues: {},
      selectedValues: {}, // Clear all selected values
      dynamicAttributes: [], // Clear dynamic attributes
      selectedAttributeValues: {}, // Clear selected attribute values
      childCategoryHistory: childCategoryHistory,
      attributeOptionsVisibility: {}, // Reset visibility states
    ));
  }

// Add a helper method to completely reset selections
  void resetAllSelections() {
    emit(state.copyWith(
      selectedValues: {},
      selectedAttributeValues: {},
      numericFieldValues: {},
      dynamicAttributes: [],
      attributeOptionsVisibility: {},
      childCategorySelections: {},
      childCategoryDynamicAttributes: {},
    ));
  }

  void _handleDynamicAttributeCreation(
    AttributeModel attribute,
    AttributeValueModel value,
    List<AttributeModel> dynamicAttributes,
  ) {
    if (attribute.subFilterWidgetType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      // Generate a unique key for the child attribute to prevent conflicts
      final childAttributeKey = '${attribute.attributeKey}_child';

      // Remove any existing dynamic attributes for this parent attribute
      dynamicAttributes.removeWhere(
        (attr) => attr.attributeKey == childAttributeKey,
      );

      // Create new dynamic attribute without any selected values
      final newAttribute = AttributeModel(
        attributeKey: childAttributeKey, // Use unique key
        helperText: attribute.subHelperText,
        subHelperText: 'null',
        widgetType: attribute.subWidgetsType,
        subWidgetsType: 'null',
        filterText: attribute.subFilterText,
        subFilterText: 'null',
        filterWidgetType: attribute.subFilterWidgetType,
        subFilterWidgetType: 'null',
        dataType: 'string',
        values: value.list.map((subModel) {
          return AttributeValueModel(
            attributeValueId: subModel.modelId ?? '',
            attributeKeyId: subModel.attributeId ?? '',
            value: subModel.name ?? '',
            list: [],
          );
        }).toList(),
      );

      dynamicAttributes.insert(0, newAttribute);
    }
  }

  void selectAttributeValue(
      AttributeModel attribute, AttributeValueModel value) {
    final Map<String, dynamic> newSelectedValues =
        Map<String, dynamic>.from(state.selectedValues);
    final Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map<AttributeModel, AttributeValueModel>.from(
            state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List<AttributeModel>.from(state.dynamicAttributes);

    if (attribute.filterWidgetType == 'oneSelectable') {
      final currentValue = newSelectedValues[attribute.attributeKey];
      if (currentValue == value) return;

      if (attribute.subFilterWidgetType != 'null') {
        final childKey = '${attribute.attributeKey}_child';
        newSelectedValues.remove(childKey);

        newSelectedAttributeValues
            .removeWhere((attr, _) => attr.attributeKey == childKey);

        _handleDynamicAttributeCreation(
          attribute,
          value,
          newDynamicAttributes,
        );
      }

      newSelectedValues[attribute.attributeKey] = value;
      newSelectedAttributeValues[attribute] = value;
    } else {
      newSelectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValueModel>[]);
      final list = newSelectedValues[attribute.attributeKey]
          as List<AttributeValueModel>;
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }

  AttributeValueModel? getSelectedAttributeValue(AttributeModel attribute) {
    return state.selectedAttributeValues[attribute];
  }

  dynamic getSelectedValues(AttributeModel attribute) {
    final selectedValue = state.selectedValues[attribute.attributeKey];
    if (attribute.filterWidgetType == 'oneSelectable') {
      return selectedValue;
    } else {
      if (selectedValue == null) {
        return <AttributeValueModel>[];
      }
      if (selectedValue is List<AttributeValueModel>) {
        return selectedValue;
      }
      if (selectedValue is AttributeValueModel) {
        return <AttributeValueModel>[selectedValue];
      }
      return <AttributeValueModel>[];
    }
  }

  void clearSelectedAttribute(AttributeModel attribute) {
    final Map<String, dynamic> newSelectedValues =
        Map<String, dynamic>.from(state.selectedValues);
    final Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map<AttributeModel, AttributeValueModel>.from(
            state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List<AttributeModel>.from(state.dynamicAttributes);

    // Remove the attribute value
    newSelectedValues.remove(attribute.attributeKey);
    newSelectedAttributeValues.remove(attribute);

    // If this is a parent attribute, remove all related dynamic attributes and their values
    if (attribute.subFilterWidgetType != 'null') {
      final childKey = '${attribute.attributeKey}_child';

      // Remove dynamic attributes
      newDynamicAttributes.removeWhere((attr) => attr.attributeKey == childKey);

      // Remove values for child attributes
      newSelectedValues.remove(childKey);

      // Remove from selectedAttributeValues
      newSelectedAttributeValues
          .removeWhere((attr, _) => attr.attributeKey == childKey);
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }

  void clearAllSelectedAttributes() {
    emit(state.copyWith(
      selectedValues: {},
      selectedAttributeValues: {},
      dynamicAttributes: [],
      attributeOptionsVisibility: {},
    ));
    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
    }
  }

  void resetSelection() {
    emit(HomeTreeState());
  }

  void resetCatalogSelection() {
    emit(state.copyWith(
      clearSelectedCatalog: true,
      clearSelectedChildCategory: true,
      selectedCatalog: null,
      selectedChildCategory: null,
      childCategorySelections: {},
      childCategoryDynamicAttributes: {},
    ));
  }

  void resetChildCategorySelection() {
    if (state.selectedCatalog != null) {
      final Map<String, Map<String, dynamic>> newSelections =
          Map.from(state.childCategorySelections);
      final Map<String, List<AttributeModel>> newDynamicAttributes =
          Map.from(state.childCategoryDynamicAttributes);

      if (state.selectedChildCategory != null) {
        newSelections.remove(state.selectedChildCategory!.id);
        newDynamicAttributes.remove(state.selectedChildCategory!.id);
      }

      emit(state.copyWith(
        clearSelectedChildCategory: true,
        selectedChildCategory: null,
        childCategorySelections: newSelections,
        childCategoryDynamicAttributes: newDynamicAttributes,
        selectedAttributeValues: {},
        attributeOptionsVisibility: {},
      ));
    }
  }

  void resetSelectionForChildCategory(ChildCategoryModel newChildCategory) {
    final Map<String, Map<String, dynamic>> newSelections =
        Map.from(state.childCategorySelections);
    final Map<String, List<AttributeModel>> newDynamicAttributes =
        Map.from(state.childCategoryDynamicAttributes);

    newSelections.remove(newChildCategory.id);
    newDynamicAttributes.remove(newChildCategory.id);

    emit(state.copyWith(
      attributeOptionsVisibility: {},
      selectedAttributeValues: {},
      childCategorySelections: newSelections,
      childCategoryDynamicAttributes: newDynamicAttributes,
      selectedValues: {},
      dynamicAttributes: [],
    ));
  }

  void clear() {
    emit(HomeTreeState());
  }

  void clearSelectedAttributeValue(
      AttributeModel attribute, AttributeValueModel value) {
    final Map<String, dynamic> newSelectedValues =
        Map<String, dynamic>.from(state.selectedValues);
    final Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map<AttributeModel, AttributeValueModel>.from(
            state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List<AttributeModel>.from(state.dynamicAttributes);

    // For single-select attributes
    if (attribute.filterWidgetType == 'oneSelectable') {
      // Only clear if the selected value matches the value to be cleared
      if (newSelectedAttributeValues[attribute] == value) {
        newSelectedValues.remove(attribute.attributeKey);
        newSelectedAttributeValues.remove(attribute);

        // Handle dynamic attributes for parent-child relationships
        if (attribute.subFilterWidgetType != 'null') {
          final childKey = '${attribute.attributeKey}_child';
          newSelectedValues.remove(childKey);
          newSelectedAttributeValues
              .removeWhere((attr, _) => attr.attributeKey == childKey);
          newDynamicAttributes
              .removeWhere((attr) => attr.attributeKey == childKey);
        }
      }
    }
    // For multi-select attributes
    else {
      final list = newSelectedValues[attribute.attributeKey]
          as List<AttributeValueModel>?;
      if (list != null) {
        list.remove(value);

        // If the list becomes empty, remove the entire entry
        if (list.isEmpty) {
          newSelectedValues.remove(attribute.attributeKey);
          newSelectedAttributeValues.remove(attribute);
        }
      }
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }

  bool isValueSelected(AttributeModel attribute, AttributeValueModel value) {
    final selectedValue = state.selectedValues[attribute.attributeKey];
    if (attribute.filterWidgetType == 'oneSelectable') {
      return selectedValue == value;
    } else if (attribute.filterWidgetType != 'oneSelectable') {
      final selectedList = selectedValue as List<AttributeValueModel>?;
      return selectedList?.contains(value) ?? false;
    }
    return false;
  }

  void preserveAttributeState(
      AttributeModel oldAttribute, AttributeModel newAttribute) {
    final Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    final Map<AttributeModel, AttributeValueModel> newSelectedValues =
        Map.from(state.selectedAttributeValues);

    if (newVisibility.containsKey(oldAttribute)) {
      newVisibility[newAttribute] = newVisibility[oldAttribute]!;
    }
    if (newSelectedValues.containsKey(oldAttribute)) {
      newSelectedValues[newAttribute] = newSelectedValues[oldAttribute]!;
    }

    emit(state.copyWith(
      attributeOptionsVisibility: newVisibility,
      selectedAttributeValues: newSelectedValues,
    ));
  }

  void setNumericFieldRange(String fieldId, int? from, int? to) {
    final Map<String, Map<String, int>> newNumericFieldValues =
        Map<String, Map<String, int>>.from(state.numericFieldValues);

    // If both values are null, remove the field
    if (from == null && to == null) {
      newNumericFieldValues.remove(fieldId);
    } else {
      // Create or update the range for this field
      newNumericFieldValues[fieldId] = {
        'from': from ?? 0,
        'to': to ?? 0,
      };
    }

    emit(state.copyWith(
      numericFieldValues: newNumericFieldValues,
      filtersTrigered: true,
    ));

    // Trigger search or fetch based on current state
    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
    }
  }

  void clearNumericField(String fieldId) {
    final Map<String, Map<String, int>> newNumericFieldValues =
        Map<String, Map<String, int>>.from(state.numericFieldValues);

    newNumericFieldValues.remove(fieldId);

    emit(state.copyWith(
      numericFieldValues: newNumericFieldValues,
      filtersTrigered: true,
    ));

    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
    }
  }

  void clearAllNumericFields() {
    emit(state.copyWith(
      numericFieldValues: {},
      filtersTrigered: true,
    ));

    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
    }
  }

  Map<String, int>? getNumericFieldValues(String fieldId) {
    return state.numericFieldValues[fieldId];
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _filterPredictionDebounceTimer?.cancel();
    _filterPredictionCancelToken?.cancel();
    return super.close();
  }
}

extension AttributeFilterHelper on HomeTreeState {
  List<String> generateFilterParameters() {
    final List<String> filters = [];

    // Handle single-selection attributes
    selectedAttributeValues.forEach((attribute, value) {
      if (value.attributeKeyId.isNotEmpty &&
          value.attributeValueId.isNotEmpty) {
        filters.add('${value.attributeKeyId}:${value.attributeValueId}');

        // Handle child attributes if they exist
        final childAttribute = dynamicAttributes.firstWhere(
          (attr) => attr.attributeKey == '${attribute.attributeKey}_child',
          orElse: () => attribute,
        );

        final childValue = selectedAttributeValues[childAttribute];
        if (childValue != null &&
            childValue.attributeKeyId.isNotEmpty &&
            childValue.attributeValueId.isNotEmpty) {
          filters.add(
              '${childValue.attributeKeyId}:${childValue.attributeValueId}');
        }
      }
    });

    // Handle multi-selection attributes
    selectedValues.forEach((key, value) {
      if (value is List<AttributeValueModel>) {
        for (var attrValue in value) {
          if (attrValue.attributeKeyId.isNotEmpty &&
              attrValue.attributeValueId.isNotEmpty) {
            filters.add(
                '${attrValue.attributeKeyId}:${attrValue.attributeValueId}');
          }
        }

        // Handle child attributes for multi-select
        if (value.isNotEmpty && value.first.list.isNotEmpty) {
          final childKey = '${key}_child';
          final childValues = selectedValues[childKey];

          if (childValues is List<AttributeValueModel>) {
            for (var childValue in childValues) {
              if (childValue.attributeKeyId.isNotEmpty &&
                  childValue.attributeValueId.isNotEmpty) {
                filters.add(
                    '${childValue.attributeKeyId}:${childValue.attributeValueId}');
              }
            }
          }
        }
      }
    });

    // Debug print all filters
    debugPrint('🔍 Generated Filters:');
    for (var filter in filters) {
      debugPrint('  → $filter');
    }

    return filters;
  }

  List<String> _generateNumericFilters() {
    final List<String> filters = [];

    numericFieldValues.forEach((fieldId, range) {
      final fromValue = range['from'];
      final toValue = range['to'];

      if (fromValue != null || toValue != null) {
        final from = (fromValue == null || fromValue == double.negativeInfinity)
            ? ''
            : fromValue.toString();
        final to = (toValue == null || toValue == double.infinity)
            ? ''
            : toValue.toString();

        if (from.isNotEmpty || to.isNotEmpty) {
          filters.add('$fieldId:$from~$to');
        }
      }
    });

    return filters;
  }
}

extension HomeTreeStateFilterTracking on HomeTreeState {
  bool hasFilterChanges(HomeTreeState previous) {
    final previousFilters = Set.from(previous.generateFilterParameters());
    final currentFilters = Set.from(generateFilterParameters());

    return !setEquals(previousFilters, currentFilters);
  }

  // Helper method to check if any filters are applied
  bool hasAnyFilters() {
    return selectedAttributeValues.isNotEmpty ||
        selectedValues.isNotEmpty ||
        numericFieldValues.isNotEmpty;
  }
}
