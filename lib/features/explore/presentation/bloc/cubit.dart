// post_cubit.dart
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

  void selectAttributeValue(
      AttributeModel attribute, AttributeValueModel value) {
    Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
    Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map.from(state.selectedAttributeValues);

    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      final currentValue = newSelectedValues[attribute.attributeKey];
      if (currentValue == value) return;

      newSelectedValues[attribute.attributeKey] = value;
      _handleDynamicAttributeCreation(attribute, value);
    } else if (attribute.widgetType == 'multiSelectable') {
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

    newSelectedAttributeValues[attribute] = value;

    emit(state.copyWith(
      selectedValues: newSelectedValues,
      selectedAttributeValues: newSelectedAttributeValues,
    ));
  }

  void _handleDynamicAttributeCreation(
      AttributeModel attribute, AttributeValueModel value) {
    if (attribute.subWidgetsType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      List<AttributeModel> newDynamicAttributes =
          List.from(state.dynamicAttributes);

      bool alreadyExists = newDynamicAttributes.any((attr) =>
          attr.attributeKey == attribute.attributeKey &&
          attr.subWidgetsType == 'null' &&
          attr.values.length == value.list.length &&
          attr.values.every((existingValue) => value.list
              .any((newValue) => existingValue.value == newValue.name)));

      if (!alreadyExists) {
        final newAttribute = AttributeModel(
          attributeKey: attribute.attributeKey,
          helperText: attribute.subHelperText,
          subHelperText: 'null',
          widgetType: attribute.subWidgetsType,
          subWidgetsType: 'null',
          dataType: 'string',
          values: value.list.map((subModel) {
            return AttributeValueModel(
              attributeValueId: subModel.modelId ?? '',
              attributeKeyId: '',
              value: subModel.name ?? '',
              list: [],
            );
          }).toList(),
        );

        newDynamicAttributes.removeWhere(
          (attr) =>
              attr.attributeKey == attribute.attributeKey &&
              attr.subWidgetsType == 'null',
        );

        newDynamicAttributes.insert(0, newAttribute);

        emit(state.copyWith(dynamicAttributes: newDynamicAttributes));
      }
    }
  }

  void toggleAttributeOptionsVisibility(AttributeModel attribute) {
    Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    newVisibility[attribute] = !(newVisibility[attribute] ?? false);

    emit(state.copyWith(attributeOptionsVisibility: newVisibility));
  }

  void confirmMultiSelection(AttributeModel attribute) {
    if (attribute.widgetType == 'multiSelectable') {
      final selectedValues = state.selectedValues[attribute.attributeKey]
              as List<AttributeValueModel>? ??
          [];
      if (selectedValues.isEmpty) return;

      List<AttributeModel> newDynamicAttributes =
          List.from(state.dynamicAttributes);
      newDynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

      final dynamicAttributesToAdd = selectedValues
          .where((value) =>
              attribute.subWidgetsType != 'null' &&
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
      emit(state.copyWith(dynamicAttributes: newDynamicAttributes));
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

  List<AttributeRequestValue> getAttributeRequestsForPost() {
    List<AttributeRequestValue> requests = [];
    Set<String> processedCombinations = {};

    state.selectedAttributeValues.forEach((attribute, value) {
      if (attribute.widgetType == 'oneSelectable' ||
          attribute.widgetType == 'colorSelectable') {
        String combinationKey =
            '${value.attributeKeyId}_${value.attributeValueId}';

        if (!processedCombinations.contains(combinationKey)) {
          processedCombinations.add(combinationKey);

          if (value.attributeKeyId.isNotEmpty &&
              value.attributeValueId.isNotEmpty) {
            requests.add(AttributeRequestValue(
              attributeId: value.attributeKeyId,
              attributeValueIds: [value.attributeValueId],
            ));
          }

          // Handle child attributes
          if (value.list.isNotEmpty &&
              value.list.first.attributeId != null &&
              value.list.first.modelId != null) {
            String childKey =
                '${value.list.first.attributeId}_${value.list.first.modelId}';

            if (!processedCombinations.contains(childKey) &&
                value.list.first.attributeId!.isNotEmpty &&
                value.list.first.modelId!.isNotEmpty) {
              processedCombinations.add(childKey);
              requests.add(AttributeRequestValue(
                attributeId: value.list.first.attributeId!,
                attributeValueIds: [value.list.first.modelId!],
              ));
            }
          }
        }
      }
    });

    state.selectedValues.forEach((key, value) {
      if (value is List<AttributeValueModel>) {
        List<AttributeValueModel> values = value;
        if (values.isNotEmpty) {
          String attributeId = values.first.attributeKeyId;
          List<String> valueIds =
              values.map((v) => v.attributeValueId).toList();

          if (attributeId.isNotEmpty && valueIds.isNotEmpty) {
            requests.add(AttributeRequestValue(
              attributeId: attributeId,
              attributeValueIds: valueIds,
            ));

            for (var value in values) {
              if (value.list.isNotEmpty &&
                  value.list.first.attributeId != null &&
                  value.list.first.modelId != null) {
                String childKey =
                    '${value.list.first.attributeId}_${value.list.first.modelId}';

                if (!processedCombinations.contains(childKey) &&
                    value.list.first.attributeId!.isNotEmpty &&
                    value.list.first.modelId!.isNotEmpty) {
                  processedCombinations.add(childKey);
                  requests.add(AttributeRequestValue(
                    attributeId: value.list.first.attributeId!,
                    attributeValueIds: [value.list.first.modelId!],
                  ));
                }
              }
            }
          }
        }
      }
    });

    return requests;
  }

  bool isAttributeOptionsVisible(AttributeModel attribute) {
    return state.attributeOptionsVisibility[attribute] ?? false;
  }

  AttributeValueModel? getSelectedAttributeValue(AttributeModel attribute) {
    return state.selectedAttributeValues[attribute];
  }

  bool isValueSelected(AttributeModel attribute, AttributeValueModel value) {
    final selectedValue = state.selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue == value;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValueModel>?;
      return selectedList?.contains(value) ?? false;
    }
    return false;
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
    if (attribute.widgetType == 'multiSelectable') {
      return (state.selectedValues[attribute.attributeKey]
              as List<AttributeValueModel>?) ??
          [];
    }
    return [];
  }

  void clearSelection(AttributeModel attribute) {
    if (attribute.widgetType == 'multiSelectable') {
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
      var parentAttribute = state.currentAttributes.firstWhere(
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

// Optional helper method to clear attributes for specific widget types
  void clearAttributesByType(String widgetType) {
    Map<String, dynamic> newSelectedValues = Map.from(state.selectedValues);
    Map<AttributeModel, bool> newVisibility =
        Map.from(state.attributeOptionsVisibility);
    Map<AttributeModel, AttributeValueModel> newSelectedAttributeValues =
        Map.from(state.selectedAttributeValues);
    List<AttributeModel> newDynamicAttributes =
        List.from(state.dynamicAttributes);

    // Get all attributes of the specified type
    final attributesToClear =
        state.currentAttributes.where((attr) => attr.widgetType == widgetType);

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
//
