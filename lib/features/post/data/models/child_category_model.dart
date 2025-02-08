import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:hive/hive.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
part 'child_category_model.g.dart';

@HiveType(typeId: 1)
class ChildCategoryModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  List<AttributeModel> attributes;
  @HiveField(4)
  String logoUrl;
  @HiveField(5)
  List<NomericFieldModel> numericFields;

  ChildCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.attributes,
    required this.logoUrl,
    required this.numericFields,
  });

  factory ChildCategoryModel.fromJson(Map<String, dynamic> json) {
    return ChildCategoryModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      description: json['description'],
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
