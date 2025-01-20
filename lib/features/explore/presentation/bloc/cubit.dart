// post_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/get_publications_usecase.dart';
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
  static const int pageSize = 20;

  HomeTreeCubit({
    required this.getCatalogsUseCase,
    required this.getPublicationsUseCase,
  }) : super(HomeTreeState());

  Future<void> fetchPage(int pageKey) async {
    if (state.isPublicationsLoading) return;
    debugPrint("🔍 Fetching page: $pageKey with search: ${state.searchText}");

    if (pageKey == 0) {
      // For first page, we clear everything
      emit(state.copyWith(
        isPublicationsLoading: true,
        errorPublicationsFetch: null,
        publications: [], // Clear existing publications
        hasReachedMax: false,
        currentPage: 0,
      ));
    } else {
      // For subsequent pages, keep existing data but show loading
      emit(state.copyWith(
        isPublicationsLoading: true,
        errorPublicationsFetch: null,
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
            isPublicationsLoading: false,
            errorPublicationsFetch: _mapFailureToMessage(failure),
          ));
        },
        (newPublications) {
          final isLastPage = newPublications.length < pageSize;

          // Only append for pagination, replace for new search
          final List<GetPublicationEntity> updatedPublications;
          if (pageKey == 0) {
            updatedPublications = newPublications;
          } else {
            updatedPublications = [...state.publications, ...newPublications];
          }

          emit(state.copyWith(
            isPublicationsLoading: false,
            errorPublicationsFetch: null,
            publications: updatedPublications,
            hasReachedMax: isLastPage,
            currentPage: pageKey,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isPublicationsLoading: false,
        errorPublicationsFetch: 'An unexpected error occurred',
      ));
    }
  }

  bool isHandlingSearch = false;
// Add this new method for search handling
  Future<void> handleSearch(String? searchText) async {
    isHandlingSearch = true;
    // First clear everything and set new search text
    emit(state.copyWith(
      searchText: searchText,
      publications: [], // Clear existing publications
      currentPage: 0,
      hasReachedMax: false,
      isPublicationsLoading: false,
      errorPublicationsFetch: null,
    ));

    // Then fetch the first page with new search text
    await fetchPage(0);
     isHandlingSearch = false;
  }


  

  void setPriceRange(double? from, double? to) {
    emit(state.copyWith(
      priceFrom: from,
      priceTo: to,
    ));
  }

  void clearPriceRange() {
    emit(state.copyWith(
      priceFrom: null,
      priceTo: null,
    ));
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

            // Check if there's a selected value for this child attribute
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
  }

  void confirmMultiSelection(AttributeModel attribute) {
    if (attribute.filterWidgetType != 'oneSelectable') {
      final selectedValues = state.selectedValues[attribute.attributeKey]
              as List<AttributeValueModel>? ??
          [];
      if (selectedValues.isEmpty) return;

      List<AttributeModel> newDynamicAttributes =
          List<AttributeModel>.from(state.dynamicAttributes);

      newDynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

      final dynamicAttributesToAdd = selectedValues
          .where((value) =>
              attribute.subFilterWidgetType != 'null' &&
              value.list.isNotEmpty &&
              value.list.any((subModel) =>
                  subModel.name != null && subModel.name!.isNotEmpty))
          .map((value) => AttributeModel(
                attributeKey:
                    '${attribute.attributeKey} Model - ${value.value}',
                helperText: attribute.subHelperText,
                subHelperText: 'null',
                widgetType: attribute.subWidgetsType,
                subWidgetsType: 'null',
                filterText: attribute.filterText,
                subFilterText: 'null',
                filterWidgetType: attribute.filterWidgetType,
                subFilterWidgetType: 'null',
                dataType: 'string',
                values: value.list
                    .where((subModel) =>
                        subModel.name != null && subModel.name!.isNotEmpty)
                    .map((subModel) => AttributeValueModel(
                          attributeValueId: subModel.modelId ?? '',
                          attributeKeyId: '',
                          value: subModel.name ?? '',
                          list: [],
                        ))
                    .toList(),
              ))
          .toList();

      newDynamicAttributes.insertAll(0, dynamicAttributesToAdd);

      emit(state.copyWith(
        dynamicAttributes: newDynamicAttributes,
      ));
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
}
