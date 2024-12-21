
import 'package:list_in/features/post/data/models/sub_model.dart';

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