import 'package:list_in/features/profile/domain/entity/user_data_entity.dart';
class UserDataModel {
  final String id;
  final String? nickName;
  final bool enableCalling;
  final String? phoneNumber;
  final String? fromTime;
  final String? toTime;
  final String? email;
  final String? profileImagePath;
  final double? rating;  // Changed to nullable
  final bool isGrantedForPreciseLocation;
  final String? locationName;
  final double? longitude;
  final double? latitude;
  final String role;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  UserDataModel({
    required this.id,
    this.nickName,
    required this.enableCalling,
    this.phoneNumber,
    this.fromTime,
    this.toTime,
    this.email,
    this.profileImagePath,
    this.rating,  // Made nullable
    required this.isGrantedForPreciseLocation,
    this.locationName,
    this.longitude,
    this.latitude,
    required this.role,
    required this.dateCreated,
    required this.dateUpdated,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as String,
      nickName: json['nickName'] as String?,
      enableCalling: json['enableCalling'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      fromTime: json['fromTime'] as String?,
      toTime: json['toTime'] as String?,
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      rating: json['rating'] == null ? null : (json['rating'] as num).toDouble(),
      isGrantedForPreciseLocation: json['isGrantedForPreciseLocation'] as bool? ?? false,
      locationName: json['locationName'] as String?,
      longitude: json['longitude'] == null ? null : (json['longitude'] as num).toDouble(),
      latitude: json['latitude'] == null ? null : (json['latitude'] as num).toDouble(),
      role: json['role'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateUpdated: DateTime.parse(json['dateUpdated'] as String),
    );
  }

  UserDataEntity toEntity() {
    return UserDataEntity(
      id: id,
      nickName: nickName,
      enableCalling: enableCalling,
      phoneNumber: phoneNumber,
      fromTime: fromTime,
      toTime: toTime,
      email: email,
      profileImagePath: profileImagePath,
      rating: rating ?? 0.0,  // Provide default value when converting to entity
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