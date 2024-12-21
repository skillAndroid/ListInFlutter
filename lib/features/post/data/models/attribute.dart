
import 'package:list_in/features/post/data/models/attribute_value.dart';

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