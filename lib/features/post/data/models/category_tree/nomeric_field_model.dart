import 'package:hive/hive.dart';
part 'nomeric_field_model.g.dart';

@HiveType(typeId: 5)
class NomericFieldModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String fieldName;
  @HiveField(2)
  String fieldNameUz;
  @HiveField(3)
  String fieldNameRu;
  @HiveField(4)
  String description;
  @HiveField(5)
  String descriptionUz;
  @HiveField(6)
  String descriptionRu;

  NomericFieldModel({
    required this.id,
    required this.fieldName,
    required this.fieldNameUz,
    required this.fieldNameRu,
    required this.description,
    required this.descriptionUz,
    required this.descriptionRu,
  });

  factory NomericFieldModel.fromJson(Map<String, dynamic> json) {
    return NomericFieldModel(
      id: json['id'] ?? '',
      fieldName: json['fieldName'] ?? '',
      fieldNameUz: json['fieldNameUz'] ?? '',
      fieldNameRu: json['fieldNameRu'] ?? '',
      description: json['description'] ?? '',
      descriptionUz: json['descriptionUz'] ?? '',
      descriptionRu: json['descriptionRu'] ?? '',
    );
  }
}
//
