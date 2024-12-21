import 'package:list_in/features/post/data/models/child_category.dart';

class Category {
  String id;
  String name;
  String description;
  List<ChildCategory> childCategories;

  Category(
      {required this.id,
      required this.name,
      required this.description,
      required this.childCategories});
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      childCategories: (json['childCategories'] as List?)
              ?.map((e) => ChildCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
