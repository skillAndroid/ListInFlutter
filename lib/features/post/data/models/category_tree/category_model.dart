import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';
import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel {
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
  List<ChildCategoryModel> childCategories;
  @HiveField(8)
  String logoUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.nameUz,
    required this.description,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.childCategories,
    required this.logoUrl,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUz: json['nameUz'] as String,
      nameRu: json['nameRu'] as String,
      description: json['description'] as String? ?? '',
      descriptionUz: json['descriptionUz'] as String? ?? '',
      descriptionRu: json['descriptionRu'] as String? ?? '',
      logoUrl: json['logoUrl'] as String,
      childCategories: (json['childCategories'] as List?)
              ?.map(
                  (e) => ChildCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
