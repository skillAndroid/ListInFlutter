import 'package:list_in/features/profile/domain/entity/another_user/another_user_profile_entity.dart';

class AnotherUserProfileModel {
  final String? id;
  final String? nickName;
  final bool? enableCalling;
  final String? phoneNumber;
  final String? biography;
  final String? fromTime;
  final String? toTime;
  final String? email;
  final String? profileImagePath;
  final num? rating;
  final bool? isGrantedForPreciseLocation;
  final String? locationName;
  final double? longitude;
  final int? followers;
  final int? following;
  final bool? isFollowing;
  final double? latitude;
  final String? role;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;

  AnotherUserProfileModel({
    this.id,
    this.nickName,
    this.enableCalling,
    this.phoneNumber,
    this.biography,
    this.fromTime,
    this.toTime,
    this.email,
    this.profileImagePath,
    this.rating,
    this.isGrantedForPreciseLocation,
    this.locationName,
    this.longitude,
    this.followers,
    this.following,
    this.isFollowing,
    this.latitude,
    this.role,
    this.dateCreated,
    this.dateUpdated,
  });

  factory AnotherUserProfileModel.fromJson(Map<String, dynamic> json) {
    return AnotherUserProfileModel(
      id: json['id'] as String?,
      nickName: json['nickName'] as String?,
      enableCalling: json['enableCalling'] as bool?,
      phoneNumber: json['phoneNumber'] as String?,
      biography: json['biography'] as String?,
      fromTime: json['fromTime'] as String?,
      toTime: json['toTime'] as String?,
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      rating: json['rating'] as num?,
      isGrantedForPreciseLocation: json['isGrantedForPreciseLocation'] as bool?,
      locationName: json['locationName'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      isFollowing: json['isFollowing'] as bool?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      role: json['role'] as String?,
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'] as String)
          : null,
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'enableCalling': enableCalling,
      'phoneNumber': phoneNumber,
      'biography': biography,
      'fromTime': fromTime,
      'toTime': toTime,
      'email': email,
      'profileImagePath': profileImagePath,
      'rating': rating,
      'isGrantedForPreciseLocation': isGrantedForPreciseLocation,
      'locationName': locationName,
      'longitude': longitude,
      'followers': followers,
      'following': following,
      'isFollowing': isFollowing,
      'latitude': latitude,
      'role': role,
      'dateCreated': dateCreated?.toIso8601String(),
      'dateUpdated': dateUpdated?.toIso8601String(),
    };
  }

  AnotherUserProfileEntity toEntity() {
    return AnotherUserProfileEntity(
      id: id,
      nickName: nickName,
      phoneNumber: phoneNumber,
      rating: rating,
      isGrantedForPreciseLocation: isGrantedForPreciseLocation ?? false,
      longitude: longitude,
      latitude: latitude,
      fromTime: fromTime,
      locationName: locationName,
      toTime: toTime,
      biography: biography,
      isFollowing: isFollowing,
      followers: followers,
      following: following,
      email: email,
      role: role,
      enableCalling: enableCalling,
      profileImagePath: profileImagePath,
      dateCreated: dateCreated,
      dateUpdated: dateCreated,
    );
  }
}
