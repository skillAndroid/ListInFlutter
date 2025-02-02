import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';

class UpdatePostModel extends UpdatePostEntity {
  UpdatePostModel({
    required super.title,
    required super.description,
    required super.price,
    required super.imageUrls,
    required super.videoUrl,
    required super.productCondition,
    required super.isNegatable,
  });

  factory UpdatePostModel.fromJson(Map<String, dynamic> json) {
    return UpdatePostModel(
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      videoUrl: json['videoUrl'] as String?,
      productCondition: json['productCondition'] as String,
      isNegatable: json['bargain'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'productCondition': productCondition,
      'bargain': isNegatable,
    };
  }
}
