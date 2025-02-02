import 'package:list_in/features/profile/data/model/publication/update_user_post_model.dart';

class UpdatePostEntity {
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String? videoUrl;
  final bool isNegatable;
  final String productCondition;

  UpdatePostEntity({
    required this.isNegatable,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.videoUrl,
    required this.productCondition,
  });

  UpdatePostModel toModel() => UpdatePostModel(
        title: title,
        description: description,
        price: price,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        productCondition: productCondition,
        isNegatable: isNegatable,
      );
}
