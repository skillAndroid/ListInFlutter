import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
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
    required super.locationSharingMode,
    required super.phoneNumber,
    required super.allowCalls,
    required super.callStartTime,
    required super.callEndTime,
    required super.productCondition,
    required super.isNegatable,
    required super.childCategoryId,
    required super.attributeValues,
    required super.numericFieldValues,
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
      locationSharingMode: LocationSharingMode.values
          .firstWhere((e) => e.toString() == json['locationSharingMode']),
      productCondition: json['productCondition'] as String,
      isNegatable: json['bargain'] as bool,
      childCategoryId: json['categoryId'] as String,
      attributeValues: (json['attributeValues'] as List)
          .map((attr) => AttributeRequestValue(
                attributeId: attr['attributeId'] as String,
                attributeValueIds: List<String>.from(attr['attributeValueIds']),
              ))
          .toList(),
      numericFieldValues: (json['numericFields'] as Map<String, dynamic>)
          .entries
          .map((entry) => NumericRequestValue(
                numericFieldId: entry.key,
                numericValue: entry.value.toDouble, // Приводим к строке
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
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'locationSharingMode': locationSharingMode.toString(),
      'productCondition': productCondition,
      'bargain': isNegatable,
      'categoryId': childCategoryId,
      'attributeValues': attributeValues.map((attr) => attr.toJson()).toList(),
      'numericFields': numericFieldValues, // Add this line
    };
  }
}
