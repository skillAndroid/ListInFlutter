import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';

class PredictionModel {
  final String? name;
  final String? categoryId;
  final String? childCategoryId;

  PredictionModel({
    required this.categoryId,
    required this.childCategoryId,
    required this.name,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      categoryId: json["parentCategoryId"],
      childCategoryId: json["categoryId"],
      name: json["model"],
    );
  }

  PredictionEntity toEntity() {
    return PredictionEntity(
      categoryId: categoryId,
      childCategoryId: childCategoryId,
      name: name,
    );
  }
}
