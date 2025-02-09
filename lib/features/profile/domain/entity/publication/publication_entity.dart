import 'package:list_in/features/profile/domain/entity/publication/category_entity.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_image_entity.dart';
class PublicationEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool bargain;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<PublicationImageEntity> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryEntity category;
  final AttributeValueEntity attributeValue; // Changed from List<AttributeEntity>

  PublicationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.bargain,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.productImages,
    this.videoUrl,
    required this.publicationType,
    required this.productCondition,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.attributeValue,
  });
}

class AttributeValueEntity {
  final String parentCategory;
  final String category;
  final Map<String, dynamic> attributes;
  final dynamic numericValues;

  AttributeValueEntity({
    required this.parentCategory,
    required this.category,
    required this.attributes,
    this.numericValues,
  });
}