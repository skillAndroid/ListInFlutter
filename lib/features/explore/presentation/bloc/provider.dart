// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/presentation/pages/catalog_screen.dart';

class HomeTreeProvider extends ChangeNotifier {
  final GetGategoriesUsecase getCatalogsUseCase;

  HomeTreeProvider({
    required this.getCatalogsUseCase,
  });

  List<AttributeRequestValue> attributeRequests = [];

  void getAtributesForPost() {
    // Clear previous requests
    attributeRequests.clear();

    // Set to track processed attribute-value combinations
    final Set<String> processedCombinations = {};

    // Handle single-selection attributes (oneSelectable and colorSelectable)
    for (var entry in _selectedAttributeValues.entries) {
      AttributeModel attribute = entry.key;
      AttributeValueModel value = entry.value;

      if (attribute.filterWidgetType == 'oneSelectable') {
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
          }

          if (attribute.subFilterText != 'null' &&
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

    for (var entry in _selectedValues.entries) {
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

    debugPrint("Attribute requests:");
    for (var request in attributeRequests) {
      print("Attribute ID: ${request.attributeId}");
      print("Attribute Value IDs: ${request.attributeValueIds.join(', ')}");
      print("------------");
    }
  }

  final PostCreationState _postCreationState = PostCreationState.initial;
  String? _postCreationError;

  PostCreationState get postCreationState => _postCreationState;
  String? get postCreationError => _postCreationError;

  List<CategoryModel>? _catalogs;
  CategoryModel? _selectedCatalog;
  ChildCategoryModel? _selectedChildCategory;
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, dynamic>> _childCategorySelections = {};
  final Map<String, List<AttributeModel>> _childCategoryDynamicAttributes = {};

  List<AttributeModel> _currentAttributes = [];
  List<AttributeModel> dynamicAttributes = [];
  final Map<String, dynamic> _selectedValues = {};

  final List<CategoryModel> _catalogHistory = [];
  final List<ChildCategoryModel> _childCategoryHistory = [];

  List<CategoryModel>? get catalogs => _catalogs;
  CategoryModel? get selectedCatalog => _selectedCatalog;
  ChildCategoryModel? get selectedChildCategory => _selectedChildCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AttributeModel> get currentAttributes {
    if (dynamicAttributes.isEmpty) return _currentAttributes;
    final List<AttributeModel> orderedAttributes = [];
    for (var attr in _currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }

  Map<String, dynamic> get selectedValues => _selectedValues;
  final Map<AttributeModel, bool> _attributeOptionsVisibility = {};
  final Map<AttributeModel, AttributeValueModel> _selectedAttributeValues = {};
  void toggleAttributeOptionsVisibility(AttributeModel attribute) {
    _attributeOptionsVisibility[attribute] =
        !(_attributeOptionsVisibility[attribute] ?? false);
    notifyListeners();
  }

  bool isAttributeOptionsVisible(AttributeModel attribute) {
    return _attributeOptionsVisibility[attribute] ?? false;
  }

  AttributeValueModel? getSelectedAttributeValue(AttributeModel attribute) {
    return _selectedAttributeValues[attribute];
  }

  Future<void> fetchCatalogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCatalogsUseCase(params: NoParams());
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _catalogs = null;
      },
      (catalogs) {
        _catalogs = catalogs;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
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
    if (_selectedCatalog == null || _selectedCatalog?.id != catalog.id) {
      _childCategorySelections.clear();
      _childCategoryDynamicAttributes.clear();
    }

    if (_selectedCatalog != null &&
        !_catalogHistory.contains(_selectedCatalog)) {
      _catalogHistory.add(_selectedCatalog!);
    }
    _selectedCatalog = catalog;
    _selectedChildCategory = null;
    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    notifyListeners();
  }

  void selectChildCategory(ChildCategoryModel childCategory) {
    final previousChildCategoryId = _selectedChildCategory?.id;
    if (previousChildCategoryId != null &&
        previousChildCategoryId != childCategory.id) {
      resetSelectionForChildCategory(childCategory);
    }
    if (_selectedChildCategory != null &&
        !_childCategoryHistory.contains(_selectedChildCategory)) {
      _childCategoryHistory.add(_selectedChildCategory!);
    }
    _selectedChildCategory = childCategory;
    _currentAttributes = childCategory.attributes;
    if (_selectedChildCategory?.id != childCategory.id) {
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;
      if (_childCategorySelections.containsKey(childCategory.id)) {
        _selectedValues.clear();
        _selectedValues.addAll(_childCategorySelections[childCategory.id]!);
        dynamicAttributes =
            _childCategoryDynamicAttributes[childCategory.id] ?? [];
      } else {
        _selectedValues.clear();
        dynamicAttributes.clear();
      }
      if (previousChildCategoryId != null &&
          previousChildCategoryId != childCategory.id) {
        final preservedDynamicAttributes =
            dynamicAttributes.where((dynamicAttr) {
          return _currentAttributes.any(
              (attr) => dynamicAttr.attributeKey.startsWith(attr.attributeKey));
        }).toList();
        dynamicAttributes = preservedDynamicAttributes;
      }
    }
    notifyListeners();
  }

  void goBack() {
    if (_selectedChildCategory != null) {
      _saveCurrentSelections();
      if (_childCategoryHistory.isNotEmpty) {
        final previousChildCategory = _childCategoryHistory.removeLast();
        _selectedChildCategory = previousChildCategory;
        _restorePreviousSelections();
        _currentAttributes = previousChildCategory.attributes;
      } else {
        _selectedChildCategory = null;
        resetUIState();
        _selectedValues.clear();
        // dynamicAttributes.clear();
        // _currentAttributes.clear();
      }
    } else if (_selectedCatalog != null) {
      if (_catalogHistory.isNotEmpty) {
        _selectedCatalog = _catalogHistory.removeLast();
      } else {
        _selectedCatalog = null;
      }
      resetUIState();
    }
    notifyListeners();
  }

  void _saveCurrentSelections() {
    if (_selectedChildCategory != null) {
      _childCategorySelections[_selectedChildCategory!.id] =
          Map<String, dynamic>.from(_selectedValues);
      _childCategoryDynamicAttributes[_selectedChildCategory!.id] =
          List<AttributeModel>.from(dynamicAttributes);
    }
  }

  void _restorePreviousSelections() {
    if (_selectedChildCategory != null) {
      _selectedValues.clear();
      _selectedValues
          .addAll(_childCategorySelections[_selectedChildCategory!.id] ?? {});
      dynamicAttributes.clear();
      dynamicAttributes.addAll(
          _childCategoryDynamicAttributes[_selectedChildCategory!.id] ?? []);
      _currentAttributes = _selectedChildCategory!.attributes;
    }
  }

  void selectAttributeValue(
      AttributeModel attribute, AttributeValueModel value) {
    if (attribute.filterWidgetType == 'oneSelectable') {
      final currentValue = _selectedValues[attribute.attributeKey];
      if (currentValue == value) return;
      _selectedValues[attribute.attributeKey] = value;
      _handleDynamicAttributeCreation(attribute, value);
    } else {
      _selectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValueModel>[]);
      final list =
          _selectedValues[attribute.attributeKey] as List<AttributeValueModel>;
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    }
    _selectedAttributeValues[attribute] = value;
    notifyListeners();
  }

  void _handleDynamicAttributeCreation(
      AttributeModel attribute, AttributeValueModel value) {
    if (attribute.subFilterWidgetType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      bool alreadyExists = dynamicAttributes.any((attr) =>
          attr.attributeKey == attribute.attributeKey &&
          attr.subFilterWidgetType == 'null' &&
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
          filterText: attribute.filterText,
          subFilterText: attribute.subFilterText,
          filterWidgetType: attribute.filterWidgetType,
          subFilterWidgetType: attribute.subFilterWidgetType,
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

        dynamicAttributes.removeWhere(
          (attr) =>
              attr.attributeKey == attribute.attributeKey &&
              attr.subWidgetsType == 'null',
        );

        dynamicAttributes.insert(0, newAttribute);
      }
    }
  }

  bool isValueSelected(AttributeModel attribute, AttributeValueModel value) {
    final selectedValue = _selectedValues[attribute.attributeKey];
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
    if (_attributeOptionsVisibility.containsKey(oldAttribute)) {
      _attributeOptionsVisibility[newAttribute] =
          _attributeOptionsVisibility[oldAttribute]!;
    }
    if (_selectedAttributeValues.containsKey(oldAttribute)) {
      _selectedAttributeValues[newAttribute] =
          _selectedAttributeValues[oldAttribute]!;
    }
  }

  void confirmMultiSelection(AttributeModel attribute) {
    if (attribute.filterWidgetType != 'oneSelectable') {
      final selectedValues = _selectedValues[attribute.attributeKey]
              as List<AttributeValueModel>? ??
          [];
      if (selectedValues.isEmpty) return;

      dynamicAttributes.removeWhere((attr) =>
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

      dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
    }

    notifyListeners();
  }

  AttributeValueModel? getSelectedValue(AttributeModel attribute) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.filterWidgetType == 'oneSelectable') {
      return selectedValue as AttributeValueModel?;
    } else if (attribute.filterWidgetType != 'oneSelectable') {
      final selectedList = selectedValue as List<AttributeValueModel>?;
      return selectedList!.isNotEmpty ? selectedList.first : null;
    }
    return null;
  }

  void resetCatalogSelection() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();
  }

  void resetChildCategorySelection() {
    _selectedChildCategory = null;
    if (_selectedCatalog != null) {
      _childCategorySelections.remove(_selectedChildCategory?.id);
      _childCategoryDynamicAttributes.remove(_selectedChildCategory?.id);
      _selectedAttributeValues.clear();
      _attributeOptionsVisibility.clear();
    }
  }

  void resetSelection() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    _catalogHistory.clear();
    _childCategoryHistory.clear();
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();
    notifyListeners();
  }

  void resetUIState() {
    _attributeOptionsVisibility.clear();
    notifyListeners();
  }

  void resetSelectionForChildCategory(ChildCategoryModel newChildCategory) {
    _attributeOptionsVisibility.clear();
    _selectedAttributeValues.clear();
    _childCategorySelections.remove(newChildCategory.id);
    _childCategoryDynamicAttributes.remove(newChildCategory.id);
    _selectedValues.clear();
    dynamicAttributes.clear();
    notifyListeners();
  }

  void clear() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _catalogHistory.clear();
    _childCategoryHistory.clear();

    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    _attributeOptionsVisibility.clear();
    _selectedAttributeValues.clear();
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();

    notifyListeners();
  }
}
