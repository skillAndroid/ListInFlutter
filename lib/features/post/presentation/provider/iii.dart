import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogModel? _catalogModel;
  Catalog? _selectedCatalog;
  ChildCategory? _selectedChildCategory;

  // Map to store selected values for each child category
  final Map<String, Map<String, dynamic>> _childCategorySelections = {};

  // Map to store dynamic attributes for each child category
  final Map<String, List<Attribute>> _childCategoryDynamicAttributes = {};

  List<Attribute> _currentAttributes = [];
  List<Attribute> _dynamicAttributes = [];
  final Map<String, dynamic> _selectedValues = {};

  final List<Catalog> _catalogHistory = [];
  final List<ChildCategory> _childCategoryHistory = [];

  CatalogModel? get catalogModel => _catalogModel;
  Catalog? get selectedCatalog => _selectedCatalog;
  ChildCategory? get selectedChildCategory => _selectedChildCategory;

  List<Attribute> get currentAttributes {
    if (_dynamicAttributes.isEmpty) return _currentAttributes;
    final List<Attribute> orderedAttributes = [];
    for (var attr in _currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = _dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }

  Map<String, dynamic> get selectedValues => _selectedValues;

  void loadCatalog(String jsonString) {
    _catalogModel = CatalogModel.fromJson(jsonString);
    notifyListeners();
  }

  void selectCatalog(Catalog catalog) {
    // If selecting a different catalog, clear previous selections
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
    _dynamicAttributes = [];
    _selectedValues.clear();
    notifyListeners();
  }

  void selectChildCategory(ChildCategory childCategory) {
    // Check if this child category was previously selected
    final previousChildCategoryId = _selectedChildCategory?.id;

    if (_selectedChildCategory != null &&
        !_childCategoryHistory.contains(_selectedChildCategory)) {
      _childCategoryHistory.add(_selectedChildCategory!);
    }

    if (_selectedChildCategory?.id != childCategory.id) {
      // If it's a new child category, reset or load previous state
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;

      // Check if we have a previous selection for this child category
      if (_childCategorySelections.containsKey(childCategory.id)) {
        // Restore previous selections
        _selectedValues.clear();
        _selectedValues.addAll(_childCategorySelections[childCategory.id]!);

        // Restore dynamic attributes
        _dynamicAttributes =
            _childCategoryDynamicAttributes[childCategory.id] ?? [];
      } else {
        // First time selecting this child category
        _selectedValues.clear();
        _dynamicAttributes.clear();
      }

      // If we're switching to a completely new child category, reset dynamic attributes
      if (previousChildCategoryId != null &&
          previousChildCategoryId != childCategory.id) {
        final preservedDynamicAttributes =
            _dynamicAttributes.where((dynamicAttr) {
          return _currentAttributes.any(
              (attr) => dynamicAttr.attributeKey.startsWith(attr.attributeKey));
        }).toList();
        _dynamicAttributes = preservedDynamicAttributes;
      }
    }
    notifyListeners();
  }

  void goBack() {
    if (_selectedChildCategory != null) {
      // Save current selections before going back
      _saveCurrentSelections();

      if (_childCategoryHistory.isNotEmpty) {
        _selectedChildCategory = _childCategoryHistory.removeLast();

        // Restore previous selections for the child category
        _restorePreviousSelections();
      } else {
        _selectedChildCategory = null;
        _selectedValues.clear();
        _dynamicAttributes.clear();
        _currentAttributes.clear();
      }
    } else if (_selectedCatalog != null) {
      if (_catalogHistory.isNotEmpty) {
        _selectedCatalog = _catalogHistory.removeLast();
      } else {
        _selectedCatalog = null;
      }
    }
    notifyListeners();
  }

  void _saveCurrentSelections() {
    if (_selectedChildCategory != null) {
      // Save selected values
      _childCategorySelections[_selectedChildCategory!.id] =
          Map<String, dynamic>.from(_selectedValues);

      // Save dynamic attributes
      _childCategoryDynamicAttributes[_selectedChildCategory!.id] =
          List<Attribute>.from(_dynamicAttributes);
    }
  }

  void _restorePreviousSelections() {
    if (_selectedChildCategory != null) {
      // Restore previous selections
      _selectedValues.clear();
      _selectedValues
          .addAll(_childCategorySelections[_selectedChildCategory!.id] ?? {});

      // Restore dynamic attributes
      _dynamicAttributes.clear();
      _dynamicAttributes.addAll(
          _childCategoryDynamicAttributes[_selectedChildCategory!.id] ?? []);

      // Update current attributes
      _currentAttributes = _selectedChildCategory!.attributes;
    }
  }

  void selectAttributeValue(Attribute attribute, AttributeValue value) {
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      // Check if this value is already selected
      final currentValue = _selectedValues[attribute.attributeKey];
      if (currentValue == value) return;

      _selectedValues[attribute.attributeKey] = value;
      _handleDynamicAttributeCreation(attribute, value);
    } else if (attribute.widgetType == 'multiSelectable') {
      _selectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValue>[]);
      final list =
          _selectedValues[attribute.attributeKey] as List<AttributeValue>;
      if (list.contains(value)) {
        list.remove(value);
        _dynamicAttributes.removeWhere((attr) => attr.attributeKey
            .contains('${attribute.attributeKey} Model - ${value.value}'));
      } else {
        list.add(value);
      }
    }
    notifyListeners();
  }

  void _handleDynamicAttributeCreation(
      Attribute attribute, AttributeValue value) {
    // Remove any existing dynamic attributes for this parent attribute
    _dynamicAttributes.removeWhere((attr) =>
        attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

    // Only create new dynamic attribute if the selected value has a valid list
    if (attribute.subWidgetsType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      final newAttribute = Attribute(
        attributeKey: '${attribute.attributeKey} Model',
        helperText: attribute.subHelperText,
        subHelperText: 'null',
        widgetType: attribute.subWidgetsType,
        subWidgetsType: 'null',
        dataType: 'string',
        values: value.list.map((subModel) {
          return AttributeValue(
            attributeValueId: subModel.modelId ?? '',
            attributeKeyId: '',
            value: subModel.name ?? '',
            list: [],
          );
        }).toList(),
      );

      // Insert the new dynamic attribute
      _dynamicAttributes.insert(0, newAttribute);
    }
  }

  bool isValueSelected(Attribute attribute, AttributeValue value) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue == value;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValue>?;
      return selectedList?.contains(value) ?? false;
    }
    return false;
  }

 void confirmMultiSelection(Attribute attribute) {
  // Only proceed if the attribute is multi-selectable
  if (attribute.widgetType == 'multiSelectable') {
    // Safely get selected values, defaulting to an empty list
    final selectedValues = _selectedValues[attribute.attributeKey] as List<AttributeValue>? ?? [];

    // Temporarily store existing dynamic attributes to preserve their values
    final existingDynamicAttributes = <Attribute>[];

    // Remove and collect existing dynamic attributes related to this attribute
    _dynamicAttributes.removeWhere((attr) {
      if (attr.attributeKey.startsWith('${attribute.attributeKey} Model')) {
        // If the dynamic attribute has a non-empty value, keep it
        if (selectedValues.any((selectedValue) => 
            attr.attributeKey.contains(selectedValue.value) && 
            attr.values.isNotEmpty)) {
          existingDynamicAttributes.add(attr);
          return false;
        }
        return true;
      }
      return false;
    });

    // List to store new dynamic attributes
    final dynamicAttributesToAdd = <Attribute>[];

    // Process each selected value
    for (var value in selectedValues) {
      // Skip if the sub-widgets type is 'null' or the list is empty
      if (attribute.subWidgetsType == 'null' || value.list.isEmpty) {
        continue;
      }

      // Filter out list items with null or empty names
      final validSubModels = value.list.where((subModel) => 
        subModel.name != null && subModel.name!.isNotEmpty
      ).toList();

      // Skip if no valid sub-models
      if (validSubModels.isEmpty) {
        continue;
      }

      // Find an existing attribute for this value, if any
      final existingAttr = existingDynamicAttributes.firstWhere(
        (attr) => attr.attributeKey.contains(value.value),
        orElse: () => Attribute(
          attributeKey: '',
          helperText: '',
          subHelperText: 'null',
          widgetType: '',
          subWidgetsType: 'null',
          dataType: '',
          values: [],
        ),
      );

      // Create new dynamic attribute
      final newAttribute = Attribute(
        attributeKey: '${attribute.attributeKey} Model - ${value.value}',
        helperText: attribute.subHelperText,
        subHelperText: 'null',
        widgetType: attribute.subWidgetsType,
        subWidgetsType: 'null',
        dataType: 'string',
        values: validSubModels.map((subModel) {
          return AttributeValue(
            attributeValueId: subModel.modelId ?? '',
            attributeKeyId: '',
            value: subModel.name ?? '',
            list: [],
          );
        }).toList(),
      );

      // Preserve existing values if possible
      if (existingAttr.values.isNotEmpty) {
        newAttribute.values = existingAttr.values;
      }

      // Add the new attribute if it has valid values
      if (newAttribute.values.isNotEmpty) {
        dynamicAttributesToAdd.add(newAttribute);
      }
    }

    // Remove existing dynamic attributes for this attribute
    _dynamicAttributes.removeWhere(
      (attr) => attr.attributeKey.startsWith('${attribute.attributeKey} Model')
    );

    // Add the new dynamic attributes
    _dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
  }

  // Notify listeners of changes
  notifyListeners();
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
    }
  }

  void resetSelection() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _currentAttributes = [];
    _dynamicAttributes = [];
    _selectedValues.clear();
    _catalogHistory.clear();
    _childCategoryHistory.clear();
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();
    notifyListeners();
  }
}
