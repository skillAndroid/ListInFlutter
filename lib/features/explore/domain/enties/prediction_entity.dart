class PredictionEntity {
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

  PredictionEntity({
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
}
