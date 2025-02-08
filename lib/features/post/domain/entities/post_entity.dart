import 'package:flutter/material.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/post_model.dart';

class PostEntity {
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? locationName;
  final double latitude;
  final double longitude;
  final LocationSharingMode locationSharingMode;
  final String phoneNumber;
  final bool allowCalls;
  final TimeOfDay callStartTime;
  final TimeOfDay callEndTime;
  final bool isNegatable;
  final String productCondition;
  final String childCategoryId;
  final List<AttributeRequestValue> attributeValues;
  final List<NumericRequestValue> numericValues; 

  PostEntity({
    required this.isNegatable,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.videoUrl,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.locationSharingMode,
    required this.phoneNumber,
    required this.allowCalls,
    required this.callStartTime,
    required this.callEndTime,
    required this.productCondition,
    required this.childCategoryId,
    required this.attributeValues,
    required this.numericValues,
  });

  PostModel toModel() => PostModel(
      title: title,
      description: description,
      price: price,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      locationSharingMode: locationSharingMode,
      phoneNumber: phoneNumber,
      allowCalls: allowCalls,
      callStartTime: callStartTime,
      callEndTime: callEndTime,
      productCondition: productCondition,
      isNegatable: isNegatable,
      childCategoryId: childCategoryId,
      attributeValues: attributeValues,
      numericValues: numericValues,);
}
