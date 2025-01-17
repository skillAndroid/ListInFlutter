import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class PublicationModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool bargain;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<ProductImageModel> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryModel category;
  final SellerModel seller;

  PublicationModel({
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

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      bargain: json['bargain'],
      locationName: json['locationName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      productImages: (json['productImages'] as List)
          .map((image) => ProductImageModel.fromJson(image))
          .toList(),
      videoUrl: json['videoUrl'],
      publicationType: json['publicationType'],
      productCondition: json['productCondition'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: CategoryModel.fromJson(json['category']),
      seller: SellerModel.fromJson(json['seller']),
    );
  }

  PublicationEntity toEntity() {
    return PublicationEntity(
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
      seller: seller.toEntity(),
    );
  }
}

class ProductImageModel {
  final bool isPrimary;
  final String url;

  ProductImageModel({
    required this.isPrimary,
    required this.url,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      isPrimary: json['isPrimary'],
      url: json['url'],
    );
  }

  ProductImageEntity toEntity() {
    return ProductImageEntity(
      isPrimary: isPrimary,
      url: url,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? parentCategoryId;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentCategoryId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      parentCategoryId: json['parentCategoryId'],
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      parentCategoryId: parentCategoryId,
    );
  }
}

class SellerModel {
  final String id;
  final String nickName;
  final bool enableCalling;
  final String phoneNumber;
  final String fromTime;
  final String toTime;
  final String email;
  final String? profileImagePath;
  final double rating;
  final bool isGrantedForPreciseLocation;
  final String locationName;
  final double longitude;
  final double latitude;
  final String role;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  SellerModel({
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

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'],
      nickName: json['nickName'],
      enableCalling: json['enableCalling'],
      phoneNumber: json['phoneNumber'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      email: json['email'],
      profileImagePath: json['profileImagePath'],
      rating: json['rating'].toDouble(),
      isGrantedForPreciseLocation: json['isGrantedForPreciseLocation'],
      locationName: json['locationName'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      role: json['role'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateUpdated: DateTime.parse(json['dateUpdated']),
    );
  }

  SellerEntity toEntity() {
    return SellerEntity(
      id: id,
      nickName: nickName,
      enableCalling: enableCalling,
      phoneNumber: phoneNumber,
      fromTime: fromTime,
      toTime: toTime,
      email: email,
      profileImagePath: profileImagePath,
      rating: rating,
      isGrantedForPreciseLocation: isGrantedForPreciseLocation,
      locationName: locationName,
      longitude: longitude,
      latitude: latitude,
      role: role,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
    );
  }
}