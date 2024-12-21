import 'package:equatable/equatable.dart';
import 'package:list_in/features/post/data/models/child_category.dart';

class Catalog extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<ChildCategory> childCategories;

  const Catalog({
    required this.id,
    required this.name,
    required this.description,
    required this.childCategories,
  });

  @override
  List<Object?> get props => [id, name, description, childCategories];
}
