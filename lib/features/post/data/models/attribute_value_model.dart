import 'package:list_in/features/post/data/models/sub_model.dart';
import 'package:hive/hive.dart';
part 'attribute_value_model.g.dart';

@HiveType(typeId: 3)
class AttributeValueModel {
  @HiveField(0)
  String attributeValueId;
  @HiveField(1)
  String attributeKeyId;
  @HiveField(2)
  String value;
  @HiveField(3)
  String valueUz;
  @HiveField(4)
  String valueRu;
  @HiveField(5)
  List<SubModel> list;
  @HiveField(6)
  bool isMarkedForRemoval = false;

  AttributeValueModel({
    required this.attributeValueId,
    required this.attributeKeyId,
    required this.value,
    required this.valueUz,
    required this.valueRu,
    required this.list,
  });

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    return AttributeValueModel(
      attributeValueId: json['attributeValueId'],
      attributeKeyId: json['attributeKeyId'],
      value: json['value'],
      valueUz: json['valueUz'],
      valueRu: json['valueRu'],
      list: (json['list'] as List)
          .map((subJson) => SubModel.fromJson(subJson))
          .toList(),
    );
  }
}
