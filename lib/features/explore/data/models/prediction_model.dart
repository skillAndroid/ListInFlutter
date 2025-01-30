import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';

class PredictionModel {
  final String? childAttributeValueId;
  final String? childAttributeValue;
  final String? parentAttributeValueId;
  final String? parentAttributeValue;
  final String? parentAttributeKeyId;
  final String? childAttributeKeyId;
  final String? parentCategoryId;
  final String? parentCategoryName;
  final String? categoryId;
  final String? categoryName;

  PredictionModel({
    required this.childAttributeValueId,
    required this.childAttributeValue,
    required this.parentAttributeValueId,
    required this.parentAttributeValue,
    required this.parentAttributeKeyId,
    required this.childAttributeKeyId,
    required this.parentCategoryId,
    required this.parentCategoryName,
    required this.categoryId,
    required this.categoryName,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      childAttributeValueId: json["childAttributeValueId"],
      childAttributeValue: json["childAttributeValue"],
      parentAttributeValueId: json["parentAttributeValueId"],
      parentAttributeValue: json["parentAttributeValue"],
      parentAttributeKeyId: json["parentAttributeKeyId"],
      childAttributeKeyId: json["childAttributeKeyId"],
      parentCategoryId: json["parentCategoryId"],
      parentCategoryName: json["parentCategoryName"],
      categoryId: json["categoryId"],
      categoryName: json["categoryName"],
    );
  }

  PredictionEntity toEntity() {
    return PredictionEntity(
        childAttributeValueId: childAttributeValueId,
        childAttributeValue: childAttributeValue,
        parentAttributeValueId: parentAttributeValueId,
        parentAttributeValue: parentAttributeValue,
        parentAttributeKeyId: parentAttributeKeyId,
        childAttributeKeyId: childAttributeKeyId,
        parentCategoryId: parentCategoryId,
        parentCategoryName: parentCategoryName,
        categoryId: categoryId,
        categoryName: categoryName);
  }
}
