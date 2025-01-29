class PredictionEntity {
  final String? name;
  final String? categoryId;
  final String? childCategoryId;

  PredictionEntity({
    required this.categoryId,
    required this.childCategoryId,
    required this.name,
  });
}
