import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:hive/hive.dart';
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

  ChildCategoryModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.attributes});

  factory ChildCategoryModel.fromJson(Map<String, dynamic> json) {
    return ChildCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      attributes: (json['attributes'] as List)
          .map((attrJson) => AttributeModel.fromJson(attrJson))
          .toList(),
    );
  }
}
