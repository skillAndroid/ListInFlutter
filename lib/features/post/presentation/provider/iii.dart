import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogModel? _catalogModel;
  Catalog? _selectedCatalog;
  ChildCategory? _selectedChildCategory;

  final Map<String, Map<String, dynamic>> _childCategorySelections = {};
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
    final previousChildCategoryId = _selectedChildCategory?.id;

    if (_selectedChildCategory != null &&
        !_childCategoryHistory.contains(_selectedChildCategory)) {
      _childCategoryHistory.add(_selectedChildCategory!);
    }

    if (_selectedChildCategory?.id != childCategory.id) {
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;

      if (_childCategorySelections.containsKey(childCategory.id)) {
        _selectedValues.clear();
        _selectedValues.addAll(_childCategorySelections[childCategory.id]!);

        _dynamicAttributes =
            _childCategoryDynamicAttributes[childCategory.id] ?? [];
      } else {
        _selectedValues.clear();
        _dynamicAttributes.clear();
      }

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
      _saveCurrentSelections();

      if (_childCategoryHistory.isNotEmpty) {
        _selectedChildCategory = _childCategoryHistory.removeLast();

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
      _childCategorySelections[_selectedChildCategory!.id] =
          Map<String, dynamic>.from(_selectedValues);
      _childCategoryDynamicAttributes[_selectedChildCategory!.id] =
          List<Attribute>.from(_dynamicAttributes);
    }
  }

  void _restorePreviousSelections() {
    if (_selectedChildCategory != null) {
      _selectedValues.clear();
      _selectedValues
          .addAll(_childCategorySelections[_selectedChildCategory!.id] ?? {});

      _dynamicAttributes.clear();
      _dynamicAttributes.addAll(
          _childCategoryDynamicAttributes[_selectedChildCategory!.id] ?? []);

      _currentAttributes = _selectedChildCategory!.attributes;
    }
  }

  void selectAttributeValue(Attribute attribute, AttributeValue value) {
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
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
      } else {
        list.add(value);
      }
    }
    notifyListeners();
  }

  void _handleDynamicAttributeCreation(
      Attribute attribute, AttributeValue value) {
    _dynamicAttributes.removeWhere((attr) =>
        attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

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
    if (attribute.widgetType == 'multiSelectable') {
      final selectedValues =
          _selectedValues[attribute.attributeKey] as List<AttributeValue>? ??
              [];

      final existingDynamicAttributes = <Attribute>[];

      _dynamicAttributes.removeWhere((attr) {
        if (attr.attributeKey.startsWith('${attribute.attributeKey} Model')) {
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

      final dynamicAttributesToAdd = <Attribute>[];

      for (var value in selectedValues) {
        if (attribute.subWidgetsType == 'null' || value.list.isEmpty) {
          continue;
        }

        final validSubModels = value.list
            .where((subModel) =>
                subModel.name != null && subModel.name!.isNotEmpty)
            .toList();

        if (validSubModels.isEmpty) {
          continue;
        }

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

        if (existingAttr.values.isNotEmpty) {
          newAttribute.values = existingAttr.values;
        }

        if (newAttribute.values.isNotEmpty) {
          dynamicAttributesToAdd.add(newAttribute);
        }
      }

      _dynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

      _dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
    }

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
