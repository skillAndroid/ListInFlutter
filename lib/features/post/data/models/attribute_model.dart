// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

import 'package:list_in/features/post/data/models/attribute_value_model.dart';

part 'attribute_model.g.dart';

@HiveType(typeId: 2)
class AttributeModel {
  @HiveField(0)
  String attributeKey;
  @HiveField(1)
  String attributeKeyUz;
  @HiveField(2)
  String attributeKeyRu;
  @HiveField(3)
  String helperText;
  @HiveField(4)
  String helperTextUz;
  @HiveField(5)
  String helperTextRu;
  @HiveField(6)
  String subHelperText;
  @HiveField(7)
  String subHelperTextUz;
  @HiveField(8)
  String subHelperTextRu;
  @HiveField(9)
  String widgetType;
  @HiveField(10)
  String subWidgetsType;
  @HiveField(11)
  String filterText;
  @HiveField(12)
  String filterTextUz;
  @HiveField(13)
  String filterTextRu;
  @HiveField(14)
  String subFilterText;
  @HiveField(15)
  String subFilterTextUz;
  @HiveField(16)
  String subFilterTextRu;
  @HiveField(17)
  String filterWidgetType;
  @HiveField(18)
  String subFilterWidgetType;
  @HiveField(19)
  String dataType;
  @HiveField(20)
  List<AttributeValueModel> values;

  AttributeModel({
    required this.attributeKey,
    required this.attributeKeyUz,
    required this.attributeKeyRu,
    required this.helperText,
    required this.helperTextUz,
    required this.helperTextRu,
    required this.subHelperText,
    required this.subHelperTextUz,
    required this.subHelperTextRu,
    required this.widgetType,
    required this.subWidgetsType,
    required this.filterText,
    required this.filterTextUz,
    required this.filterTextRu,
    required this.subFilterText,
    required this.subFilterTextUz,
    required this.subFilterTextRu,
    required this.filterWidgetType,
    required this.subFilterWidgetType,
    required this.dataType,
    required this.values,
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      attributeKey: json['attributeKey'],
      attributeKeyUz: json['attributeKeyUz'],
      attributeKeyRu: json['attributeKeyRu'],
      helperText: json['helperText'],
      helperTextUz: json['helperTextUz'],
      helperTextRu: json['helperTextRu'],
      subHelperText: json['subHelperText'] ?? 'null',
      subHelperTextUz: json['subHelperTextUz'] ?? 'null',
      subHelperTextRu: json['subHelperTextRu'] ?? 'null',
      widgetType: json['widgetType'],
      subWidgetsType: json['subWidgetType'] ?? 'null',
      filterText: json['filterText'],
      filterTextUz: json['filterTextUz'],
      filterTextRu: json['filterTextRu'],
      subFilterText: json['subFilterText'] ?? 'null',
      subFilterTextUz: json['subFilterTextUz'] ?? 'null',
      subFilterTextRu: json['subFilterTextRu'] ?? 'null',
      filterWidgetType: json['filterWidgetType'],
      subFilterWidgetType: json['subFilterWidgetType'] ?? 'null',
      dataType: json['dataType'],
      values: (json['values'] as List)
          .map((valueJson) => AttributeValueModel.fromJson(valueJson))
          .toList(),
    );
  }
}
