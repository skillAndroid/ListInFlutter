import 'package:dartz/dartz.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class GetPublicationModel {
  final String id;
  final String title;
  final String description;
  // final double price;
  final bool bargain;
  final String locationName;
  // final double? latitude;
  // final double? longitude;
  final List<ProductImageModel> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  // final DateTime createdAt;
  // final DateTime updatedAt;
  final CategoryModel category;
  final SellerModel seller;

  GetPublicationModel({
    required this.id,
    required this.title,
    required this.description,
    // required this.price,
    required this.bargain,
    required this.locationName,
    // this.latitude,
    // this.longitude,
    required this.productImages,
    this.videoUrl,
    required this.publicationType,
    required this.productCondition,
    // required this.createdAt,
    // required this.updatedAt,
    required this.category,
    required this.seller,
  });

  static double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  factory GetPublicationModel.fromJson(Map<String, dynamic> json) {
    try {
      print('📌 Starting to parse publication with ID: ${json['id']}');

      // Safe price parsing
      final dynamic priceValue = json['price'];
      double price = 0.0;
      if (priceValue != null) {
        if (priceValue is num) {
          price = priceValue.toDouble();
        } else if (priceValue is String) {
          price = double.tryParse(priceValue) ?? 0.0;
        }
      }

      // Parse product images safely
      List<ProductImageModel> images = [];
      if (json['productImages'] != null) {
        try {
          images = (json['productImages'] as List)
              .map((img) => ProductImageModel.fromJson(img))
              .toList();
        } catch (e) {
          print('⚠️ Error parsing product images: $e');
        }
      }

      return GetPublicationModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        // price: price,
        bargain: json['bargain'] ?? false,
        locationName: json['locationName']?.toString() ?? '',
        // latitude: _safeParseDouble(json['latitude']),
        // longitude: _safeParseDouble(json['longitude']),
        productImages: images,
        videoUrl: json['videoUrl']?.toString(),
        publicationType: json['publicationType']?.toString() ?? '',
        productCondition: json['productCondition']?.toString() ?? '',
        // createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        // updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
        category: CategoryModel.fromJson(json['category'] ?? {}),
        seller: SellerModel.fromJson(json['seller'] ?? {}),
      );
    } catch (e) {
     
      rethrow;
    }
  }

  GetPublicationEntity toEntity() {
    return GetPublicationEntity(
      id: id,
      title: title,
      description: description,
      // price: price,
      bargain: bargain,
      locationName: locationName,
      // latitude: latitude,
      // longitude: longitude,
      productImages: productImages.map((image) => image.toEntity()).toList(),
      videoUrl: videoUrl,
      publicationType: publicationType,
      productCondition: productCondition,
      // createdAt: createdAt,
      // updatedAt: updatedAt,
      category: category.toEntity(),
      seller: seller.toEntity(),
    );
  }
}

class ProductImageModel {
  final bool? isPrimary;
  final String url;

  ProductImageModel({
    this.isPrimary,
    required this.url,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      isPrimary: json['isPrimary'] as bool?,
      url: json['url']?.toString() ?? '',
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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parentCategoryId: json['parentCategoryId']?.toString(),
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
  // final String phoneNumber;
  // final String fromTime;
  // final String toTime;
  final String email;
  final String? profileImagePath;
  // final double? rating;
  final bool isGrantedForPreciseLocation;
  final String locationName;
  // final double? longitude;
  // final double? latitude;
  final String role;
  // final DateTime dateCreated;
  // final DateTime dateUpdated;

  SellerModel({
    required this.id,
    required this.nickName,
    required this.enableCalling,
    // required this.phoneNumber,
    // required this.fromTime,
    // required this.toTime,
    required this.email,
    this.profileImagePath,
    // this.rating,
    required this.isGrantedForPreciseLocation,
    required this.locationName,
    // this.longitude,
    // this.latitude,
    required this.role,
    // required this.dateCreated,
    // required this.dateUpdated,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    try {
      return SellerModel(
        id: json['id']?.toString() ?? '',
        nickName: json['nickName']?.toString() ?? '',
        enableCalling: json['enableCalling'] ?? false,
        // phoneNumber: json['phoneNumber']?.toString() ?? '',
        // fromTime: json['fromTime']?.toString() ?? '00:00',
        // toTime: json['toTime']?.toString() ?? '23:59',
        email: json['email']?.toString() ?? '',
        profileImagePath: json['profileImagePath']?.toString(),
        // rating: GetPublicationModel._safeParseDouble(json['rating']),
        isGrantedForPreciseLocation: json['isGrantedForPreciseLocation'] ?? false,
        locationName: json['locationName']?.toString() ?? '',
        // longitude: GetPublicationModel._safeParseDouble(json['longitude']),
        // latitude: GetPublicationModel._safeParseDouble(json['latitude']),
        role: json['role']?.toString() ?? '',
        // dateCreated: DateTime.tryParse(json['dateCreated']?.toString() ?? '') ?? DateTime.now(),
        // dateUpdated: DateTime.tryParse(json['dateUpdated']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print('❌ Error in SellerModel.fromJson: $e');
      rethrow;
    }
  }

  SellerEntity toEntity() {
    return SellerEntity(
      id: id,
      nickName: nickName,
      enableCalling: enableCalling,
      // phoneNumber: phoneNumber,
      // fromTime: fromTime,
      // toTime: toTime,
      email: email,
      profileImagePath: profileImagePath,
      // rating: rating,
      isGrantedForPreciseLocation: isGrantedForPreciseLocation,
      locationName: locationName,
      // longitude: longitude,
      // latitude: latitude,
      role: role,
      // dateCreated: dateCreated,
      // dateUpdated: dateUpdated,
    );
  }
}