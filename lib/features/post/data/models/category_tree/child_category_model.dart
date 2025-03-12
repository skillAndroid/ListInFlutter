import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:hive/hive.dart';
import 'package:list_in/features/post/data/models/category_tree/nomeric_field_model.dart';
part 'child_category_model.g.dart';

@HiveType(typeId: 1)
class ChildCategoryModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String nameUz;
  @HiveField(3)
  String nameRu;
  @HiveField(4)
  String description;
  @HiveField(5)
  String descriptionUz;
  @HiveField(6)
  String descriptionRu;
  @HiveField(7)
  List<AttributeModel> attributes;
  @HiveField(8)
  String logoUrl;
  @HiveField(9)
  List<NomericFieldModel> numericFields;

  ChildCategoryModel({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.nameRu,
    required this.description,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.attributes,
    required this.logoUrl,
    required this.numericFields,
  });

  factory ChildCategoryModel.fromJson(Map<String, dynamic> json) {
    return ChildCategoryModel(
      id: json['id'],
      name: json['name'],
      nameUz: json['nameUz'],
      nameRu: json['nameRu'],
      logoUrl: json['logoUrl'],
      description: json['description'],
      descriptionUz: json['descriptionUz'],
      descriptionRu: json['descriptionRu'],
      attributes: (json['attributes'] as List)
          .map((attrJson) => AttributeModel.fromJson(attrJson))
          .toList(),
      numericFields: (json['numericFields'] as List?)
              ?.map((fieldJson) => NomericFieldModel.fromJson(fieldJson))
              .toList() ??
          [],
    );
  }
}
