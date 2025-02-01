// post_cubit.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
import 'package:list_in/features/explore/domain/usecase/get_prediction_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_video_publications_usecase.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';

class HomeTreeCubit extends Cubit<HomeTreeState> {
  final GetGategoriesUsecase getCatalogsUseCase;
  final GetPublicationsUsecase getPublicationsUseCase;
  final GetPredictionsUseCase getPredictionsUseCase;
  final GetVideoPublicationsUsecase getVideoPublicationsUsecase;
  static const int pageSize = 20;
  Timer? _debounceTimer;
  HomeTreeCubit({
    required this.getCatalogsUseCase,
    required this.getPublicationsUseCase,
    required this.getPredictionsUseCase,
    required this.getVideoPublicationsUsecase,
  }) : super(HomeTreeState());

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
      final limitedVideos = state.videoPublications.length > 20
          ? state.videoPublications.sublist(0, 20)
          : state.videoPublications;

      if (state.videoPublications.length > 20) {
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
      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          categoryId: state.selectedCatalog?.id,
          subcategoryId: state.selectedChildCategory?.id,
          filters: state.generateFilterParameters(),
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
      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            initialPublicationsRequestState: RequestState.error,
            errorInitialPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (paginatedData) {
          // Determine isLast by checking the last item's isLast property
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;
          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;

          emit(
            state.copyWith(
              initialPublicationsRequestState: RequestState.completed,
              errorInitialPublicationsFetch: null,
              initialPublications: updatedPublications,
              initialHasReachedMax: isLastPage,
              initialCurrentPage: pageKey,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        initialPublicationsRequestState: RequestState.error,
        errorInitialPublicationsFetch: 'An unexpected error occurred',
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
      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          query: state.searchText,
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          categoryId: state.selectedCatalog?.id,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            secondaryPublicationsRequestState: RequestState.error,
            errorSecondaryPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (paginatedData) {
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;

          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;

          emit(
            state.copyWith(
              secondaryPublicationsRequestState: RequestState.completed,
              errorSecondaryPublicationsFetch: null,
              secondaryPublications: updatedPublications,
              secondaryHasReachedMax: isLastPage,
              secondaryCurrentPage: pageKey,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        secondaryPublicationsRequestState: RequestState.error,
        errorSecondaryPublicationsFetch: 'An unexpected error occurred',
      ));
    }
  }

  void filtersTrigered() {
    emit(state.copyWith(
      filtersTrigered: true,
    ));
  }

  Future<void> fetchChildPage(int pageKey) async {
    // If we're already fetching, don't start another fetch
    if (state.childPublicationsRequestState == RequestState.inProgress) {
      debugPrint(
          '🚫 Preventing duplicate publications request for page: $pageKey');
      return;
    }

    // If this is page 0, we want to ensure we're starting fresh
    if (pageKey == 0) {
      emit(state.copyWith(
        childPublicationsRequestState: RequestState.inProgress,
        childPublications: [], // Ensure we clear existing publications
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
      final result = await getPublicationsUseCase(
        params: GetPublicationsParams(
          page: pageKey,
          size: pageSize,
          priceFrom: state.priceFrom,
          priceTo: state.priceTo,
          categoryId: state.selectedCatalog?.id,
          subcategoryId: state.selectedChildCategory?.id,
          filters: state.generateFilterParameters(),
        ),
      );

      // Handle the result only if we're still mounted and the request is still relevant
      result.fold(
        (failure) {
          emit(state.copyWith(
            childPublicationsRequestState: RequestState.error,
            errorChildPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (paginatedData) {
          // For page 0, we always want to replace existing data
          final updatedPublications =
              pageKey == 0 ? paginatedData : paginatedData;
          final isLastPage =
              paginatedData.isNotEmpty ? paginatedData.last.isLast : true;

          emit(state.copyWith(
            childPublicationsRequestState: RequestState.completed,
            childPublications: updatedPublications,
            childHasReachedMax: isLastPage,
            childCurrentPage: pageKey,
            errorChildPublicationsFetch: null,
            filtersTrigered: false
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        childPublicationsRequestState: RequestState.error,
        errorChildPublicationsFetch: 'An unexpected error occurred',
      ));
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
          size: pageSize,
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

  void setPriceRange(double? from, double? to) {
    emit(state.copyWith(
      priceFrom: from,
      priceTo: to,
      filtersTrigered: true,
    ));
    if (state.searchText != null) {
      searchPage(0);
    } else {
      fetchChildPage(0);
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

  // publications get border ************************************

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
      selectedChildCategory: childCategory,
      currentAttributes: childCategory.attributes,
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

      // Clear child-related data when parent value changes
      if (attribute.subFilterWidgetType != 'null') {
        // Clear selected values for child attributes
        final childKey = '${attribute.attributeKey}_child';
        newSelectedValues.remove(childKey);

        // Remove child-related entries from selectedAttributeValues
        newSelectedAttributeValues
            .removeWhere((attr, _) => attr.attributeKey == childKey);

        // Update dynamic attributes without selecting values
        _handleDynamicAttributeCreation(
          attribute,
          value,
          newDynamicAttributes,
        );
      }

      // Only update the parent attribute's value
      newSelectedValues[attribute.attributeKey] = value;
      newSelectedAttributeValues[attribute] = value;
    } else {
      // Handle multi-select case
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

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
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
}

extension HomeTreeStateFilterTracking on HomeTreeState {
  bool hasFilterChanges(HomeTreeState previous) {
    final previousFilters = Set.from(previous.generateFilterParameters());
    final currentFilters = Set.from(generateFilterParameters());
    return !setEquals(previousFilters, currentFilters);
  }
}
