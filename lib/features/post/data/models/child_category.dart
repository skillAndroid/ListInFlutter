
import 'package:list_in/features/post/data/models/attribute.dart';

class ChildCategory {
  String id;
  String name;
  String description;
  List<Attribute> attributes;

  ChildCategory(
      {required this.id,
      required this.name,
      required this.description,
      required this.attributes});

  factory ChildCategory.fromJson(Map<String, dynamic> json) {
    return ChildCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      attributes: (json['attributes'] as List)
          .map((attrJson) => Attribute.fromJson(attrJson))
          .toList(),
    );
  }
}