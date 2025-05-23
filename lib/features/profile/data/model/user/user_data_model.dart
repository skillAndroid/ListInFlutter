import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/profile/domain/entity/user/user_data_entity.dart';

class UserDataModel {
  final String id;
  final String? nickName;
  final bool enableCalling;
  final String? phoneNumber;
  final String? fromTime;
  final String? toTime;
  final String? email;
  final String? profileImagePath;
  final double? rating;
  final bool isGrantedForPreciseLocation;
  final String? locationName;
  final double? longitude;
  final double? latitude;
  final String role;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int followers;
  final int following;
  final bool? isFollowing;
  final String? biography;
  final Country? country;
  final State? state;
  final County? county;

  UserDataModel({
    required this.id,
    this.nickName,
    required this.enableCalling,
    this.phoneNumber,
    this.fromTime,
    this.toTime,
    this.email,
    this.profileImagePath,
    this.rating, // Made nullable
    required this.isGrantedForPreciseLocation,
    this.locationName,
    this.longitude,
    this.latitude,
    required this.role,
    required this.dateCreated,
    required this.dateUpdated,
    required this.followers,
    required this.following,
    this.isFollowing,
    this.biography,
    this.country,
    this.state,
    this.county,
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
      rating:
          json['rating'] == null ? null : (json['rating'] as num).toDouble(),
      isGrantedForPreciseLocation:
          json['isGrantedForPreciseLocation'] as bool? ?? false,
      locationName: json['locationName'] as String?,
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] as num).toDouble(),
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] as num).toDouble(),
      role: json['role'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateUpdated: DateTime.parse(json['dateUpdated'] as String),
      biography: json['biography'] as String?,
      followers: json['followers'] as int,
      following: json['following'] as int,
      isFollowing: json['isFollowing'] as bool?,
      country: json['country'] != null
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      state: json['state'] != null
          ? State.fromJson(json['state'] as Map<String, dynamic>)
          : null,
      county: json['county'] != null
          ? County.fromJson(json['county'] as Map<String, dynamic>)
          : null,
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
      rating: rating ?? 0.0, // Provide default value when converting to entity
      isGrantedForPreciseLocation: isGrantedForPreciseLocation,
      locationName: locationName,
      longitude: longitude,
      latitude: latitude,
      role: role,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      isFollowing: isFollowing,
      followers: followers,
      following: following,
      biography: biography,
      country: country,
      state: state,
      county: county,
    );
  }
}
