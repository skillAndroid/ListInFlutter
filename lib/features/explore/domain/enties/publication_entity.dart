class PublicationPairEntity {
  final bool isSponsored;
  final bool isLast;
  final GetPublicationEntity firstPublication;
  final GetPublicationEntity? secondPublication;

  PublicationPairEntity({
    required this.isSponsored,
    required this.isLast,
    required this.firstPublication,
    this.secondPublication,
  });
}

class VideoPublicationsEntity {
  final bool first;
  final bool isLast;
  final int number;
  final List<GetPublicationEntity> content;

  VideoPublicationsEntity({
    required this.first,
    required this.number,
    required this.isLast,
    required this.content,
  });
}

class GetPublicationEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool bargain;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final List<ProductImageEntity> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryEntity category;
  final SellerEntity seller;

  GetPublicationEntity({
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
    required this.seller,
  });
}

class ProductImageEntity {
  final bool? isPrimary;
  final String url;

  ProductImageEntity({
    required this.isPrimary,
    required this.url,
  });
}

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

class SellerEntity {
  final String id;
  final String nickName;
  final bool enableCalling;
  final String phoneNumber;
  final String fromTime;
  final String toTime;
  final String email;
  final String? profileImagePath;
  final double? rating;
  final bool isGrantedForPreciseLocation;
  final String locationName;
  final double? longitude;
  final double? latitude;
  final String role;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  SellerEntity({
    required this.id,
    required this.nickName,
    required this.enableCalling,
    required this.phoneNumber,
    required this.fromTime,
    required this.toTime,
    required this.email,
    this.profileImagePath,
    required this.rating,
    required this.isGrantedForPreciseLocation,
    required this.locationName,
    required this.longitude,
    required this.latitude,
    required this.role,
    required this.dateCreated,
    required this.dateUpdated,
  });
}
