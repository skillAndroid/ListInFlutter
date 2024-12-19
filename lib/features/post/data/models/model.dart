import 'dart:convert';

class CatalogModel {
  List<Catalog> catalogs;
  CatalogModel({required this.catalogs});
  factory CatalogModel.fromJson(String jsonString) {
    final Map<String, dynamic> parsed = json.decode(jsonString);
    return CatalogModel(
      catalogs: (parsed['catalog'] as List)
          .map((json) => Catalog.fromJson(json))
          .toList(),
    );
  }
}

class Catalog {
  String id;
  String name;
  String description;
  List<ChildCategory> childCategories;

  Catalog(
      {required this.id,
      required this.name,
      required this.description,
      required this.childCategories});
  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      childCategories: (json['childCategories'] as List)
          .map((childJson) => ChildCategory.fromJson(childJson))
          .toList(),
    );
  }
}

class ChildCategory {
  String id;
  String name;
  String description;
  List<Attribute> attributes;

  ChildCategory(
      {required this.id,
      required this.name,
      required this.description,
      required this.attributes});

  factory ChildCategory.fromJson(Map<String, dynamic> json) {
    return ChildCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      attributes: (json['attributes'] as List)
          .map((attrJson) => Attribute.fromJson(attrJson))
          .toList(),
    );
  }
}

class Attribute {
  String attributeKey;
  String helperText;
  String subHelperText;
  String widgetType;
  String subWidgetsType;
  String dataType;
  List<AttributeValue> values;

  Attribute({
    required this.attributeKey,
    required this.helperText,
    required this.subHelperText,
    required this.widgetType,
    required this.subWidgetsType,
    required this.dataType,
    required this.values,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      attributeKey: json['attributeKey'],
      helperText: json['helperText'],
      subHelperText: json['subHelperText'] ?? 'null',
      widgetType: json['widgetType'],
      subWidgetsType: json['subWidgetType'] ?? 'null',
      dataType: json['dataType'],
      values: (json['values'] as List)
          .map((valueJson) => AttributeValue.fromJson(valueJson))
          .toList(),
    );
  }
}

class AttributeValue {
  String attributeValueId;
  String attributeKeyId;
  String value;
  List<SubModel> list;
  bool isMarkedForRemoval = false; // New property

  AttributeValue({
    required this.attributeValueId,
    required this.attributeKeyId,
    required this.value,
    required this.list,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      attributeValueId: json['attributeValueId'],
      attributeKeyId: json['attributeKeyId'],
      value: json['value'],
      list: (json['list'] as List)
          .map((subJson) => SubModel.fromJson(subJson))
          .toList(),
    );
  }
}

class SubModel {
  String? modelId;
  String? name;
  String? attributeId;
  SubModel({this.modelId, this.name, this.attributeId});
  factory SubModel.fromJson(Map<String, dynamic> json) {
    return SubModel(
      modelId: json['modelId'],
      name: json['name'],
      attributeId: json['attributeId'],
    );
  }
}
