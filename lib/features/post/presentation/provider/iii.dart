import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogModel? _catalogModel;
  Catalog? _selectedCatalog;
  ChildCategory? _selectedChildCategory;
  List<Attribute> _dynamicAttributes = [];
  List<Attribute> _currentAttributes = [];
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
    if (_selectedCatalog != null &&
        !_catalogHistory.contains(_selectedCatalog)) {
      _catalogHistory.add(_selectedCatalog!);
    }
    _selectedCatalog = catalog;
    _selectedChildCategory = null;
    _currentAttributes = [];
    _dynamicAttributes = [];
    notifyListeners();
  }

  void selectChildCategory(ChildCategory childCategory) {
    if (_selectedChildCategory != null &&
        !_childCategoryHistory.contains(_selectedChildCategory)) {
      _childCategoryHistory.add(_selectedChildCategory!);
    }

    if (_selectedChildCategory?.id != childCategory.id) {
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;
      final preservedDynamicAttributes =
          _dynamicAttributes.where((dynamicAttr) {
        return _currentAttributes.any(
            (attr) => dynamicAttr.attributeKey.startsWith(attr.attributeKey));
      }).toList();
      _dynamicAttributes = preservedDynamicAttributes;
    }
    notifyListeners();
  }

  void goBack() {
    if (_selectedChildCategory != null) {
      if (_childCategoryHistory.isNotEmpty) {
        _selectedChildCategory = _childCategoryHistory.removeLast();
      } else {
        _selectedChildCategory = null;
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

  void selectAttributeValue(Attribute attribute, AttributeValue value) {
    if (attribute.widgetType == 'oneSelectable' || attribute.widgetType == 'colorSelectable') {
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

  bool isValueSelected(Attribute attribute, AttributeValue value) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable'  || attribute.widgetType == 'colorSelectable') {
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
      final existingUnrelatedDynamicAttributes = _dynamicAttributes
          .where(
              (attr) => !attr.attributeKey.startsWith(attribute.attributeKey))
          .toList();
      _dynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith(attribute.attributeKey) &&
          !selectedValues.any((v) => attr.attributeKey.contains(v.value)));
      _dynamicAttributes.addAll(existingUnrelatedDynamicAttributes);
      final dynamicAttributesToAdd = <Attribute>[];
      for (var value in selectedValues) {
        if (attribute.subWidgetsType != 'null' && value.list.isNotEmpty) {
          bool attributeAlreadyExists = _dynamicAttributes.any((existingAttr) =>
              existingAttr.attributeKey ==
                  '${attribute.attributeKey} Model - ${value.value}' &&
              existingAttr.widgetType == attribute.subWidgetsType);
          if (!attributeAlreadyExists) {
            final newAttribute = Attribute(
              attributeKey: '${attribute.attributeKey} Model - ${value.value}',
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
            dynamicAttributesToAdd.add(newAttribute);
          }
        }
      }
      _dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
    }
    notifyListeners();
  }

  void _handleDynamicAttributeCreation(
      Attribute attribute, AttributeValue value) {
    if (attribute.subWidgetsType != 'null' && value.list.isNotEmpty) {
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
      _dynamicAttributes.removeWhere(
          (attr) => attr.attributeKey.contains(attribute.attributeKey));
      final parentIndex = _currentAttributes.indexOf(attribute);
      if (parentIndex != -1) {
        _dynamicAttributes.insert(0, newAttribute);
      }
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
    notifyListeners();
  }
}