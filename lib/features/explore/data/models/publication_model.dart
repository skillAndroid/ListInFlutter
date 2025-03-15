import 'package:flutter/foundation.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';

class VideoPublicationsModel {
  final bool isLast;
  final int number;
  final bool first;
  final List<GetPublicationModel> content;
  final int size;
  final int totalElements;
  final int totalPages;

  VideoPublicationsModel({
    required this.isLast,
    required this.content,
    required this.first,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory VideoPublicationsModel.fromJson(Map<String, dynamic> json) {
    return VideoPublicationsModel(
      isLast: json['last'] ?? false,
      first: json['first'] ?? false,
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      content: (json['content'] as List?)
              ?.map((item) => GetPublicationModel.fromJson(item))
              .toList() ??
          [],
    );
  }
  VideoPublicationsEntity toEntity() {
    return VideoPublicationsEntity(
      isLast: isLast,
      first: first,
      number: number,
      content: content.map((model) => model.toEntity()).toList(),
    );
  }
}

class GetPublicationModel {
  final String id;
  final int likes;
  final int views;
  final bool isLiked;
  final String title;
  final bool isViewed;
  final String description;
  final double price;
  final bool bargain;
  final List<ProductImageModel> productImages;
  final String? videoUrl;
  final String publicationType;
  final String productCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryModel category;
  final SellerModel seller;
  final AttributeValueModel attributeValue;
  // final Country? country;
  // final State? state;
  // final County? county;
  // final bool isGrantedForPreciseLocation;
  // final String locationName;
  // final double? longitude;
  // final double? latitude;

  GetPublicationModel({
    required this.id,
    required this.isLiked,
    required this.likes,
    required this.views,
    required this.title,
    required this.description,
    required this.price,
    required this.bargain,
    required this.isViewed,
    required this.productImages,
    this.videoUrl,
    required this.publicationType,
    required this.productCondition,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.seller,
    required this.attributeValue,
    // required this.country,
    // required this.state,
    // this.county,
    // required this.isGrantedForPreciseLocation,
    // required this.locationName,
    // this.longitude,
    // this.latitude,
  });

  factory GetPublicationModel.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        print('📌 Starting to parse publication with ID: ${json['id']}');
      }

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
          if (kDebugMode) {
            print('⚠️ Error parsing product images: $e');
          }
        }
      }
      AttributeValueModel attributeValue = AttributeValueModel.fromJson(
        json['attributeValue'] ?? {},
      );

      return GetPublicationModel(
        id: json['id']?.toString() ?? '',
        likes: json['likes'].toInt(),
        views: json['views'].toInt(),
        isLiked: json['isLiked'] as bool,
        isViewed: json['isViewed'] as bool,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: price,
        bargain: json['bargain'] ?? false,
        productImages: images,
        videoUrl: json['videoUrl']?.toString(),
        publicationType: json['publicationType']?.toString() ?? '',
        productCondition: json['productCondition']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        category: CategoryModel.fromJson(json['category'] ?? {}),
        seller: SellerModel.fromJson(json['seller'] ?? {}),
        // country: json['country'],
        // state: json['state'],
        // county: json['county'],
        // isGrantedForPreciseLocation:
        //     json['isGrantedForPreciseLocation'] ?? false,
        // locationName: json['locationName']?.toString() ?? '',
        // longitude: json['longitude'] ?? "",
        // latitude: json['latitude'] ?? "",
        attributeValue: attributeValue,
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
      price: price,
      isViewed: isViewed,
      bargain: bargain,
      productImages: productImages.map((image) => image.toEntity()).toList(),
      videoUrl: videoUrl,
      publicationType: publicationType,
      productCondition: productCondition,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category.toEntity(),
      seller: seller.toEntity(),
      attributeValue: attributeValue.toEntity(),
      isLiked: isLiked,
      likes: likes,
      views: views,
    );
  }
}

class AttributeValueModel {
  final String parentCategory;
  final String category;
  final Map<String, Map<String, List<String>>> attributes;
  final List<NumericValueField> numericValues;

  AttributeValueModel({
    required this.parentCategory,
    required this.category,
    required this.attributes,
    required this.numericValues,
  });

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    // Parse attributes
    Map<String, Map<String, List<String>>> attributes = {};
    final attributesData = json['attributes'] ?? {};
    attributesData.forEach((language, attributeData) {
      if (attributeData is Map) {
        Map<String, List<String>> languageMap = {};
        attributeData.forEach((key, value) {
          if (value is List) {
            languageMap[key] = List<String>.from(value);
          }
        });
        attributes[language] = languageMap;
      }
    });

    // Parse numeric values
    List<NumericValueField> numericValues = [];
    final numericValuesData = json['numericValues'] ?? [];
    if (numericValuesData is List) {
      numericValues = numericValuesData
          .map((item) => NumericValueField.fromJson(item))
          .toList();
    }

    return AttributeValueModel(
      parentCategory: json['parentCategory']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      attributes: attributes,
      numericValues: numericValues,
    );
  }

  AttributeValueEntity toEntity() {
    return AttributeValueEntity(
      parentCategory: parentCategory,
      category: category,
      attributes: attributes,
      numericValues: numericValues,
    );
  }
}

class NumericValueField {
  final String numericField;
  final String numericFieldUz;
  final String numericFieldRu;
  final String numericValue;

  NumericValueField({
    required this.numericField,
    required this.numericFieldUz,
    required this.numericFieldRu,
    required this.numericValue,
  });

  factory NumericValueField.fromJson(Map<String, dynamic> json) {
    return NumericValueField(
      numericField: json['numericField']?.toString() ?? '',
      numericFieldUz: json['numericFieldUz']?.toString() ?? '',
      numericFieldRu: json['numericFieldRu']?.toString() ?? '',
      numericValue: json['numericValue']?.toString() ?? '',
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
  final String phoneNumber;
  final String fromTime;
  final String toTime;
  final String email;
  final String? profileImagePath;
  final double? rating;
  final bool isFollowing;
  final int followers;
  final int followings;
  final bool isGrantedForPreciseLocation;
  final String locationName;
  final double? longitude;
  final double? latitude;
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
    this.rating,
    required this.isGrantedForPreciseLocation,
    required this.locationName,
    this.longitude,
    this.latitude,
    required this.role,
    required this.followers,
    required this.followings,
    required this.dateCreated,
    required this.dateUpdated,
    required this.isFollowing,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    try {
      return SellerModel(
        id: json['id']?.toString() ?? '',
        isFollowing: json['isFollowing'] ?? false,
        followers: json['followers'],
        followings: json['following'],
        nickName: json['nickName']?.toString() ?? '',
        enableCalling: json['enableCalling'] ?? false,
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        fromTime: json['fromTime']?.toString() ?? '00:00',
        toTime: json['toTime']?.toString() ?? '23:59',
        email: json['email']?.toString() ?? '',
        profileImagePath: json['profileImagePath']?.toString(),
        rating: json['rating'] ?? 0,
        isGrantedForPreciseLocation:
            json['isGrantedForPreciseLocation'] ?? false,
        locationName: json['locationName']?.toString() ?? '',
        longitude: json['longitude'] ?? "",
        latitude: json['latitude'] ?? "",
        role: json['role']?.toString() ?? '',
        dateCreated: DateTime.tryParse(json['dateCreated']?.toString() ?? '') ??
            DateTime.now(),
        dateUpdated: DateTime.tryParse(json['dateUpdated']?.toString() ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in SellerModel.fromJson: $e');
      }
      rethrow;
    }
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
      isFollowing: isFollowing,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      followers: followers,
      followings: followings,
    );
  }
}
