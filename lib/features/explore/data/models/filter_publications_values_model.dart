import 'package:list_in/features/explore/domain/enties/filter_prediction_values_entity.dart';

class FilterPredictionValuesModel {
  final int foundPublications;
  final double priceFrom;
  final double priceTo;

  FilterPredictionValuesModel({
    required this.foundPublications,
    required this.priceFrom,
    required this.priceTo,
  });

  factory FilterPredictionValuesModel.fromJson(Map<String, dynamic> json) {
    return FilterPredictionValuesModel(
      foundPublications: json["foundPublications"],
      priceFrom: json["priceFrom"] ?? 0,
      priceTo: json["priceTo"] ?? 0,
    );
  }
  FilterPredictionValuesEntity toEntity() {
    return FilterPredictionValuesEntity(
      foundPublications: foundPublications,
      priceFrom: priceFrom,
      priceTo: priceTo,
    );
  }
}
