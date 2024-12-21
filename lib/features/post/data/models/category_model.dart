import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  List<ChildCategoryModel> childCategories;

  CategoryModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.childCategories});
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      childCategories: (json['childCategories'] as List?)
              ?.map(
                  (e) => ChildCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
