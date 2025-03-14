import 'package:list_in/features/post/data/models/category_tree/blabla.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  PostModel({
    required super.title,
    required super.description,
    required super.price,
    required super.imageUrls,
    required super.videoUrl,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.isGrantedForPreciseLocation,
    required super.phoneNumber,
    required super.allowCalls,
    required super.callStartTime,
    required super.callEndTime,
    required super.productCondition,
    required super.isNegatable,
    required super.childCategoryId,
    required super.attributeValues,
    required super.numericValues,
    required super.countryName,
    required super.stateName,
    required super.countyName,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      videoUrl: json['videoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      allowCalls: json['enableCalling'],
      callStartTime: json['fromTime'],
      callEndTime: json['toTime'],
      locationName: json['locationName'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      isGrantedForPreciseLocation: json['isGrantedForPreciseLocation'],
      countryName: json['countryName'] as String?,
      stateName: json['stateName'] as String?,
      countyName: json['countyName'] as String?,
      productCondition: json['productCondition'] as String,
      isNegatable: json['bargain'] as bool,
      childCategoryId: json['categoryId'] as String,
      attributeValues: (json['attributeValues'] as List)
          .map((attr) => AttributeRequestValue(
                attributeId: attr['attributeId'] as String,
                attributeValueIds: List<String>.from(attr['attributeValueIds']),
              ))
          .toList(),
      numericValues: (json['numericValues'] as Map<String, dynamic>)
          .entries
          .map((entry) => NumericRequestValue(
                numericFieldId: entry.key,
                numericValue: entry.value, // Приводим к строке
              ))
          .toList(), // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      "countryName": countryName,
      "stateName": stateName,
      "countyName": countyName,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'isGrantedForPreciseLocation': isGrantedForPreciseLocation,
      'productCondition': productCondition,
      'bargain': isNegatable,
      'categoryId': childCategoryId,
      'attributeValues': attributeValues.map((attr) => attr.toJson()).toList(),
      'numericValues': numericValues, // Add this line
    };
  }
}
