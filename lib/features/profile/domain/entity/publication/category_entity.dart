class CategoryEntity {
  final String id;
  final String name;
  final String? parentCategoryId;

  CategoryEntity({
    required this.id,
    required this.name,
    this.parentCategoryId,
  });
}

class AttributeEntity {
  final String key;
  final String value;

  AttributeEntity({
    required this.key,
    required this.value,
  });
}