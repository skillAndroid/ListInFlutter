import 'package:list_in/features/profile/data/model/publication/cutegories_model.dart';
import 'package:list_in/features/profile/data/model/publication/publication_image_model.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';

class PublicationModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool bargain;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<PublicationImageModel> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoriesModel category;
  final List<AttributeModel> attributes; // Added field

   PublicationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        title = json['title'] as String,
        description = json['description'] as String,
        price = (json['price'] as num).toDouble(), // Handles both int and double
        bargain = json['bargain'] as bool,
        locationName = json['locationName'] as String,
        latitude = (json['latitude'] as num).toDouble(),
        longitude = (json['longitude'] as num).toDouble(),
        productImages = (json['productImages'] as List<dynamic>)
            .map((image) => PublicationImageModel.fromJson(image as Map<String, dynamic>))
            .toList(),
        videoUrl = json['videoUrl'] as String?,
        publicationType = json['publicationType'] as String,
        productCondition = json['productCondition'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String),
        category = CategoriesModel.fromJson(json['category'] as Map<String, dynamic>),
        attributes = (json['attributes'] as List<dynamic>)
            .map((attr) => AttributeModel.fromJson(attr as Map<String, dynamic>))
            .toList();

  PublicationEntity toEntity() => PublicationEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        bargain: bargain,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        productImages: productImages.map((image) => image.toEntity()).toList(),
        videoUrl: videoUrl,
        publicationType: publicationType,
        productCondition: productCondition,
        createdAt: createdAt,
        updatedAt: updatedAt,
        category: category.toEntity(),
        attributes: attributes.map((attr) => attr.toEntity()).toList(),
      );
}
