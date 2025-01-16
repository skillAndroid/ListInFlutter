// post_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';

class HomeTreeCubit extends Cubit<HomeTreeState> {
  final GetGategoriesUsecase getCatalogsUseCase;
  final Map<String, Map<String, dynamic>> _childCategorySelections = {};
  final Map<String, List<AttributeModel>> _childCategoryDynamicAttributes = {};

  HomeTreeCubit({
    required this.getCatalogsUseCase,
  }) : super(const HomeTreeState());

  Future<void> fetchCatalogs() async {
    emit(state.copyWith(status: PostCreationStatus.loading));

    final result = await getCatalogsUseCase(params: NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: PostCreationStatus.error,
        error: _mapFailureToMessage(failure),
        catalogs: null,
      )),
      (catalogs) => emit(state.copyWith(
        status: PostCreationStatus.initial,
        error: null,
        catalogs: catalogs,
      )),
    );
  }

  void printSelectedAttributes() {
    final selectedValues = state.selectedValues;

    selectedValues.forEach((attributeKey, value) {
      if (value is List<AttributeValueModel>) {
        // Print the list of attribute value IDs
        final valueIds = value.map((v) => v.attributeValueId).join(', ');
        debugPrint('Attribute Value IDs: $valueIds');
      } else if (value is AttributeValueModel) {
        // Print a single attribute value ID
        debugPrint('Attribute Value IDs: ${value.attributeValueId}');
      } else {
        debugPrint('No values');
      }

      debugPrint('------------');
    });
  }

  void selectCatalog(CategoryModel catalog) {
    if (state.selectedCatalog == null ||
        state.selectedCatalog?.id != catalog.id) {
      _childCategorySelections.clear();
      _childCategoryDynamicAttributes.clear();
    }

    List<CategoryModel> newHistory = List.from(state.catalogHistory);
    if (state.selectedCatalog != null &&
        !newHistory.contains(state.selectedCatalog)) {
      newHistory.add(state.selectedCatalog!);
    }

    emit(state.copyWith(
      selectedCatalog: catalog,
      selectedChildCategory: null,
      currentAttributes: [],
      dynamicAttributes: [],
      selectedValues: {},
      catalogHistory: newHistory,
    ));
  }

  void selectChildCategory(ChildCategoryModel childCategory) {
    final previousChildCategoryId = state.selectedChildCategory?.id;

    if (previousChildCategoryId != null &&
        previousChildCategoryId != childCategory.id) {
      resetSelectionForChildCategory(childCategory);
    }

    List<ChildCategoryModel> newHistory = List.from(state.childCategoryHistory);
    if (state.selectedChildCategory != null &&
        !newHistory.contains(state.selectedChildCategory)) {
      newHistory.add(state.selectedChildCategory!);
    }

    Map<String, dynamic> newSelectedValues = {};
    List<AttributeModel> newDynamicAttributes = [];

    if (_childCategorySelections.containsKey(childCategory.id)) {
      newSelectedValues = Map.from(_childCategorySelections[childCategory.id]!);
      newDynamicAttributes =
          _childCategoryDynamicAttributes[childCategory.id] ?? [];
    }

    emit(state.copyWith(
      selectedChildCategory: childCategory,
      currentAttributes: childCategory.attributes,
      selectedValues: newSelectedValues,
      dynamicAttributes: newDynamicAttributes,
      childCategoryHistory: newHistory,
    ));
  }
void selectAttributeValue(AttributeModel attribute, AttributeValueModel value) {
  Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
  Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
      Map.from(state.selectedAttributeValues);
  List<AttributeModel> newDynamicAttributes = List.from(state.dynamicAttributes);

  if (attribute.filterWidgetType == 'oneSelectable') {
    final currentValue = newSelectedValues[attribute.attributeKey];
    if (currentValue == value) return;

    // Clear existing dynamic attributes and selections for this parent
    newDynamicAttributes.removeWhere(
        (attr) => attr.attributeKey.startsWith('${attribute.attributeKey} Model'));
    newSelectedValues.removeWhere(
        (key, _) => key.startsWith('${attribute.attributeKey} Model'));
    newSelectedAttributeValues.removeWhere((attr, _) =>
        attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

    // Set the new value
    newSelectedValues[attribute.attributeKey] = value;
    newSelectedAttributeValues[attribute] = value;

    // Handle dynamic attributes creation if needed
    if (attribute.subFilterWidgetType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      try {
        final List<AttributeValueModel> validValues = value.list
            .where((subModel) =>
                subModel.name != null &&
                subModel.name!.isNotEmpty &&
                subModel.modelId != null)
            .map((subModel) => AttributeValueModel(
                  attributeValueId: subModel.modelId ?? '',
                  attributeKeyId: subModel.attributeId ?? '',
                  value: subModel.name ?? '',
                  list: [],
                ))
            .toList();

        if (validValues.isNotEmpty) {
          final newAttribute = AttributeModel(
            attributeKey: '${attribute.attributeKey} Model - ${value.value}',
            helperText: attribute.subHelperText,
            subHelperText: 'null',
            widgetType: attribute.subWidgetsType,
            subWidgetsType: 'null',
            filterText: attribute.subFilterText,
            subFilterText: 'null',
            filterWidgetType: attribute.subFilterWidgetType,
            subFilterWidgetType: 'null',
            dataType: 'string',
            values: validValues,
          );
          newDynamicAttributes.insert(0, newAttribute);
        }
      } catch (e, stackTrace) {
        debugPrint('Error creating dynamic attribute: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  } else if (attribute.filterWidgetType == 'multiSelectable' ||
      attribute.filterWidgetType == 'colorMultiSelectable') {
    newSelectedValues.putIfAbsent(
        attribute.attributeKey, () => <AttributeValueModel>[]);

    final list =
        newSelectedValues[attribute.attributeKey] as List<AttributeValueModel>;
    if (list.contains(value)) {
      list.remove(value);
      newDynamicAttributes
          .removeWhere((attr) => attr.attributeKey.contains(value.value));
    } else {
      list.add(value);
    }
  }

  emit(state.copyWith(
    selectedValues: newSelectedValues,
    selectedAttributeValues: newSelectedAttributeValues,
    dynamicAttributes: newDynamicAttributes,
  ));

  // Update attribute requests after state change
  _updateAttributeRequests();
}

void _updateAttributeRequests() {
  final List<AttributeRequestValue> attributeRequests = [];
  final Set<String> processedCombinations = {};

  // Handle single-selection attributes
  for (var entry in state.selectedAttributeValues.entries) {
    AttributeModel attribute = entry.key;
    AttributeValueModel value = entry.value;

    if (attribute.filterWidgetType == 'oneSelectable') {
      String combinationKey = '${value.attributeKeyId}_${value.attributeValueId}';
      
      if (!processedCombinations.contains(combinationKey)) {
        processedCombinations.add(combinationKey);
        
        if (value.attributeKeyId.isNotEmpty && value.attributeValueId.isNotEmpty) {
          attributeRequests.add(AttributeRequestValue(
            attributeId: value.attributeKeyId,
            attributeValueIds: [value.attributeValueId],
          ));
        }

        // Handle child attributes
        if (attribute.subHelperText != 'null' &&
            value.list.isNotEmpty &&
            value.list.first.attributeId != null &&
            value.list.first.modelId != null) {
          String childCombinationKey =
              '${value.list.first.attributeId}_${value.list.first.modelId}';
              
          if (!processedCombinations.contains(childCombinationKey) &&
              value.list.first.attributeId!.isNotEmpty &&
              value.list.first.modelId!.isNotEmpty) {
            processedCombinations.add(childCombinationKey);
            attributeRequests.add(AttributeRequestValue(
              attributeId: value.list.first.attributeId!,
              attributeValueIds: [value.list.first.modelId!],
            ));
          }
        }
      }
    }
  }

  // Handle multi-selection attributes
  for (var entry in state.selectedValues.entries) {
    if (entry.value is List<AttributeValueModel>) {
      List<AttributeValueModel> values = entry.value as List<AttributeValueModel>;
      
      if (values.isNotEmpty) {
        String attributeId = values.first.attributeKeyId;
        List<String> valueIds = values.map((v) => v.attributeValueId).toList();
        
        if (attributeId.isNotEmpty && valueIds.isNotEmpty) {
          attributeRequests.add(AttributeRequestValue(
            attributeId: attributeId,
            attributeValueIds: valueIds,
          ));

          // Handle child attributes for multi-selection
          for (var value in values) {
            if (value.list.isNotEmpty &&
                value.list.first.attributeId != null &&
                value.list.first.modelId != null) {
              String childCombinationKey =
                  '${value.list.first.attributeId}_${value.list.first.modelId}';
                  
              if (!processedCombinations.contains(childCombinationKey) &&
                  value.list.first.attributeId!.isNotEmpty &&
                  value.list.first.modelId!.isNotEmpty) {
                processedCombinations.add(childCombinationKey);
                attributeRequests.add(AttributeRequestValue(
                  attributeId: value.list.first.attributeId!,
                  attributeValueIds: [value.list.first.modelId!],
                ));
              }
            }
          }
        }
      }
    }
  }

  // Debug printing
  debugPrint("Attribute requests:");
  for (var request in attributeRequests) {
    debugPrint("Attribute ID: ${request.attributeId}");
    debugPrint("Attribute Value IDs: ${request.attributeValueIds.join(', ')}");
    debugPrint("------------");
  }

  emit(state.copyWith(attributeRequests: attributeRequests));
}
  void confirmMultiSelection(AttributeModel attribute) {
    if (attribute.filterWidgetType != 'oneSelectable') {
      try {
        final selectedValues = state.selectedValues[attribute.attributeKey]
                as List<AttributeValueModel>? ??
            [];

        // Print final selection for multi-select after confirmation

        List<AttributeModel> newDynamicAttributes =
            List<AttributeModel>.from(state.dynamicAttributes);

        // Rest of your existing confirmMultiSelection logic...
        newDynamicAttributes.removeWhere((attr) =>
            attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

        if (selectedValues.isNotEmpty) {
          final dynamicAttributesToAdd = selectedValues
              .where((value) =>
                  value.list.isNotEmpty &&
                  value.list.any((subModel) =>
                      subModel.name != null &&
                      subModel.name!.isNotEmpty &&
                      subModel.modelId != null))
              .map((value) {
            final validSubModels = value.list
                .where((subModel) =>
                    subModel.name != null &&
                    subModel.name!.isNotEmpty &&
                    subModel.modelId != null)
                .map((subModel) => AttributeValueModel(
                      attributeValueId: subModel.modelId ?? '',
                      attributeKeyId: attribute.attributeKey,
                      value: subModel.name ?? '',
                      list: [],
                    ))
                .toList();

            return AttributeModel(
              attributeKey: '${attribute.attributeKey} Model - ${value.value}',
              helperText: attribute.subHelperText,
              subHelperText: 'null',
              widgetType: attribute.subWidgetsType,
              subWidgetsType: 'null',
              filterText: attribute.subFilterText,
              subFilterText: 'null',
              filterWidgetType: attribute.subFilterWidgetType,
              subFilterWidgetType: 'null',
              dataType: 'string',
              values: validSubModels,
            );
          }).toList();

          if (dynamicAttributesToAdd.isNotEmpty) {
            newDynamicAttributes.insertAll(0, dynamicAttributesToAdd);
          }
        }
        printSelectedAttributes();
        emit(state.copyWith(
          dynamicAttributes: newDynamicAttributes,
        ));
      } catch (e, stackTrace) {
        debugPrint('Error in confirmMultiSelection: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  bool isValueSelected(AttributeModel attribute, AttributeValueModel value) {
    final selectedValue = state.selectedValues[attribute.attributeKey];

    if (selectedValue == null) return false;

    if (attribute.filterWidgetType == 'multiSelectable' ||
        attribute.filterWidgetType == 'colorMultiSelectable') {
      if (selectedValue is List<AttributeValueModel>) {
        return selectedValue.contains(value);
      }
      return false;
    } else {
      // For single select cases (oneSelectable)
      if (selectedValue is AttributeValueModel) {
        return selectedValue == value;
      }
      return false;
    }
  }

  void goBack() {
    if (state.selectedChildCategory != null) {
      _saveCurrentSelections();

      if (state.childCategoryHistory.isNotEmpty) {
        List<ChildCategoryModel> newHistory =
            List.from(state.childCategoryHistory);
        final previousChildCategory = newHistory.removeLast();
        _restorePreviousSelections(previousChildCategory);

        emit(state.copyWith(
          selectedChildCategory: previousChildCategory,
          currentAttributes: previousChildCategory.attributes,
          childCategoryHistory: newHistory,
        ));
      } else {
        emit(state.copyWith(
          selectedChildCategory: null,
          currentAttributes: [],
          selectedValues: {},
        ));
      }
    } else if (state.selectedCatalog != null) {
      if (state.catalogHistory.isNotEmpty) {
        List<CategoryModel> newHistory = List.from(state.catalogHistory);
        final previousCatalog = newHistory.removeLast();

        emit(state.copyWith(
          selectedCatalog: previousCatalog,
          catalogHistory: newHistory,
        ));
      } else {
        emit(state.copyWith(selectedCatalog: null));
      }
    }
  }

  void _saveCurrentSelections() {
    if (state.selectedChildCategory != null) {
      _childCategorySelections[state.selectedChildCategory!.id] =
          Map<String, dynamic>.from(state.selectedValues);
      _childCategoryDynamicAttributes[state.selectedChildCategory!.id] =
          List<AttributeModel>.from(state.dynamicAttributes);
    }
  }

  void _restorePreviousSelections(ChildCategoryModel childCategory) {
    emit(state.copyWith(
      selectedValues: _childCategorySelections[childCategory.id] ?? {},
      dynamicAttributes:
          _childCategoryDynamicAttributes[childCategory.id] ?? [],
      currentAttributes: childCategory.attributes,
    ));
  }

  void resetSelectionForChildCategory(ChildCategoryModel childCategory) {
    _childCategorySelections.remove(childCategory.id);
    _childCategoryDynamicAttributes.remove(childCategory.id);

    emit(state.copyWith(
      attributeOptionsVisibility: {},
      selectedAttributeValues: {},
      selectedValues: {},
      dynamicAttributes: [],
    ));
  }

  void resetSelection() {
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();

    emit(state.copyWith(
      selectedCatalog: null,
      selectedChildCategory: null,
      currentAttributes: [],
      dynamicAttributes: [],
      selectedValues: {},
      catalogHistory: [],
      childCategoryHistory: [],
    ));
  }

  bool isAttributeOptionsVisible(AttributeModel attribute) {
    return state.attributeOptionsVisibility[attribute] ?? false;
  }

  AttributeValueModel? getSelectedAttributeValue(AttributeModel attribute) {
    return state.selectedAttributeValues[attribute];
  }

  List<AttributeModel> getOrderedAttributes() {
    if (state.dynamicAttributes.isEmpty) return state.currentAttributes;

    final List<AttributeModel> orderedAttributes = [];
    for (var attr in state.currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = state.dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }

  void preserveAttributeState(
      AttributeModel oldAttribute, AttributeModel newAttribute) {
    Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    Map<AttributeModel, AttributeValueModel> newSelectedValues =
        Map.from(state.selectedAttributeValues);

    if (state.attributeOptionsVisibility.containsKey(oldAttribute)) {
      newVisibility[newAttribute] =
          state.attributeOptionsVisibility[oldAttribute]!;
    }

    if (state.selectedAttributeValues.containsKey(oldAttribute)) {
      newSelectedValues[newAttribute] =
          state.selectedAttributeValues[oldAttribute]!;
    }

    emit(state.copyWith(
      attributeOptionsVisibility: newVisibility,
      selectedAttributeValues: newSelectedValues,
    ));
  }

  List<AttributeValueModel> getSelectedValues(AttributeModel attribute) {
    final value = state.selectedValues[attribute.attributeKey];

    if (attribute.filterWidgetType != 'oneSelectable') {
      if (value is List<AttributeValueModel>) {
        return value;
      } else if (value is AttributeValueModel) {
        return [value]; // Convert single value to list
      }
    } else if (value is AttributeValueModel) {
      return [value]; // Return single value as list
    }

    return []; // Return empty list if no value or invalid type
  }

  void clearSelection(AttributeModel attribute) {
    if (attribute.filterWidgetType != 'oneSelectable') {
      Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
      newSelectedValues[attribute.attributeKey] = <AttributeValueModel>[];
      emit(state.copyWith(selectedValues: newSelectedValues));
    }
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

  void clearSelectedAttribute(AttributeModel attribute) {
    Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
    Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map.from(state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List.from(state.dynamicAttributes);

    // Check if this is a dynamic attribute
    bool isDynamicAttribute = state.dynamicAttributes.contains(attribute);

    if (isDynamicAttribute) {
      // For dynamic attributes, only clear the selection and visibility
      newSelectedValues.remove(attribute.attributeKey);
      newVisibility.remove(attribute);
      newSelectedAttributeValues.remove(attribute);

      // Find parent attribute
      String parentAttributeKey = attribute.attributeKey.split(' Model')[0];
      state.currentAttributes.firstWhere(
          (attr) => attr.attributeKey == parentAttributeKey,
          orElse: () =>
              attribute // fallback to current attribute if parent not found
          );

      // Check if parent attribute still has any selection
      var parentValue = state.selectedValues[parentAttributeKey];
      bool hasParentSelection = false;

      if (parentValue != null) {
        if (parentValue is List<AttributeValueModel>) {
          hasParentSelection = parentValue.isNotEmpty;
        } else if (parentValue is AttributeValueModel) {
          hasParentSelection = true;
        }
      }

      // Only remove dynamic attribute if parent has no selection
      if (!hasParentSelection) {
        newDynamicAttributes.removeWhere(
            (attr) => attr.attributeKey.startsWith(parentAttributeKey));
      }
    } else {
      // For regular attributes, clear everything including related dynamic attributes
      newSelectedValues.remove(attribute.attributeKey);
      newVisibility.remove(attribute);
      newSelectedAttributeValues.remove(attribute);
      newDynamicAttributes.removeWhere(
          (attr) => attr.attributeKey.startsWith(attribute.attributeKey));
    }

    // Update child category selections if needed
    if (state.selectedChildCategory != null) {
      final childCategoryId = state.selectedChildCategory!.id;
      if (_childCategorySelections.containsKey(childCategoryId)) {
        if (isDynamicAttribute) {
          // For dynamic attributes, only clear the specific value
          _childCategorySelections[childCategoryId]
              ?.remove(attribute.attributeKey);
        } else {
          // For regular attributes, clear all related values
          _childCategorySelections[childCategoryId]
              ?.remove(attribute.attributeKey);
          _childCategoryDynamicAttributes[childCategoryId]?.removeWhere(
              (attr) => attr.attributeKey.startsWith(attribute.attributeKey));
        }
      }
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      attributeOptionsVisibility: newVisibility,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }

  void clearAllSelectedAttributes() {
    // Clear all current selections
    final newSelectedValues = <String, dynamic>{};
    final newVisibility = <AttributeModel, bool>{};
    final newSelectedAttributeValues = <AttributeModel, AttributeValueModel>{};

    // Clear dynamic attributes
    final newDynamicAttributes = <AttributeModel>[];

    // If we have a selected child category, clear its stored selections
    if (state.selectedChildCategory != null) {
      final childCategoryId = state.selectedChildCategory!.id;
      _childCategorySelections.remove(childCategoryId);
      _childCategoryDynamicAttributes.remove(childCategoryId);
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      attributeOptionsVisibility: newVisibility,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }

  void clearAttributesByType(String widgetType) {
    Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
    Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map.from(state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List.from(state.dynamicAttributes);

    // Get all attributes of the specified type
    final attributesToClear = state.currentAttributes
        .where((attr) => attr.filterWidgetType == widgetType);

    for (var attribute in attributesToClear) {
      // Clear the selected value
      newSelectedValues.remove(attribute.attributeKey);

      // Clear visibility state
      newVisibility.remove(attribute);

      // Clear from selectedAttributeValues
      newSelectedAttributeValues.remove(attribute);

      // Remove associated dynamic attributes
      newDynamicAttributes.removeWhere(
          (attr) => attr.attributeKey.startsWith(attribute.attributeKey));
    }

    // Update child category selections if needed
    if (state.selectedChildCategory != null) {
      final childCategoryId = state.selectedChildCategory!.id;
      if (_childCategorySelections.containsKey(childCategoryId)) {
        for (var attribute in attributesToClear) {
          _childCategorySelections[childCategoryId]
              ?.remove(attribute.attributeKey);
        }
      }
      if (_childCategoryDynamicAttributes.containsKey(childCategoryId)) {
        for (var attribute in attributesToClear) {
          _childCategoryDynamicAttributes[childCategoryId]?.removeWhere(
              (attr) => attr.attributeKey.startsWith(attribute.attributeKey));
        }
      }
    }

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      attributeOptionsVisibility: newVisibility,
      selectedAttributeValues: newSelectedAttributeValues,
      dynamicAttributes: newDynamicAttributes,
    ));
  }
}

extension PostStateGetters on HomeTreeState {
  bool get isLoading => status == PostCreationStatus.loading;

  bool get hasError => status == PostCreationStatus.error;

  bool get isSuccess => status == PostCreationStatus.success;

  bool get canGoBack =>
      selectedChildCategory != null || selectedCatalog != null;

  bool get hasSelectedCatalog => selectedCatalog != null;

  bool get hasSelectedChildCategory => selectedChildCategory != null;

  bool get hasAttributes => currentAttributes.isNotEmpty;

  bool get hasDynamicAttributes => dynamicAttributes.isNotEmpty;

  List<AttributeModel> get allAttributes {
    if (!hasDynamicAttributes) return currentAttributes;

    final List<AttributeModel> orderedAttributes = [];
    for (var attr in currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }
}
