import 'package:equatable/equatable.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

class CatalogEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<ChildCategoryModel> childCategories;

  const CatalogEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.childCategories,
  });

  @override
  List<Object?> get props => [id, name, description, childCategories];
}
