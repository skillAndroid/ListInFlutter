import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:hive/hive.dart';
part 'attribute_model.g.dart';

@HiveType(typeId: 2)
class AttributeModel {
  @HiveField(0)
  String attributeKey;
  @HiveField(1)
  String helperText;
  @HiveField(2)
  String subHelperText;
  @HiveField(3)
  String widgetType;
  @HiveField(4)
  String subWidgetsType;
  @HiveField(5)
  String filterText;
  @HiveField(6)
  String subFilterText;
  @HiveField(7)
  String filterWidgetType;
  @HiveField(8)
  String subFilterWidgetType;
  @HiveField(9)
  String dataType;
  @HiveField(10)
  List<AttributeValueModel> values;

  AttributeModel({
    required this.attributeKey,
    required this.helperText,
    required this.subHelperText,
    required this.widgetType,
    required this.filterText,
    required this.subFilterText,
    required this.subFilterWidgetType,
    required this.filterWidgetType,
    required this.subWidgetsType,
    required this.dataType,
    required this.values,
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      attributeKey: json['attributeKey'],
      helperText: json['helperText'],
      subHelperText: json['subHelperText'] ?? 'null',
      widgetType: json['widgetType'],
      subWidgetsType: json['subWidgetType'] ?? 'null',
      filterText: json['filterText'],
      subFilterText: json['subFilterText'] ?? 'null',
      filterWidgetType: json['filterWidgetType'],
      subFilterWidgetType: json['subFilterWidgetType'] ?? 'null',
      dataType: json['dataType'],
      values: (json['values'] as List)
          .map((valueJson) => AttributeValueModel.fromJson(valueJson))
          .toList(),
    );
  }
}
//
