import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';

class UserProfileModel {
  final String? profileImagePath;
  final String? nickName;
  final String? city;
  final String? country;
  final String? county;
  final String? state;
  final String? phoneNumber;
  final bool? isGrantedForPreciseLocation;
  final String? locationName;
  final double? longitude;
  final double? latitude;
  final String? fromTime;
  final String? toTime;
  final bool? isBusinessAccount;
  final String? biography;

  UserProfileModel({
    this.profileImagePath,
    this.nickName,
    this.phoneNumber,
    this.isGrantedForPreciseLocation,
    this.locationName,
    this.city,
    this.country,
    this.state,
    this.county,
    this.longitude,
    this.latitude,
    this.fromTime,
    this.toTime,
    this.isBusinessAccount,
    this.biography,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
        profileImagePath: json['profileImagePath'] as String?,
        nickName: json['nickName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        isGrantedForPreciseLocation:
            json['isGrantedForPreciseLocation'] as bool?,
        locationName: json['locationName'] as String?,
        longitude: (json['longitude'] as num?)?.toDouble(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        fromTime: json['fromTime'] as String?,
        toTime: json['toTime'] as String?,
        isBusinessAccount: json['isBusinessAccount'] as bool?,
        biography: json['biography'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImagePath': profileImagePath,
      'nickName': nickName,
      'phoneNumber': phoneNumber,
      'isGrantedForPreciseLocation': isGrantedForPreciseLocation,
      'locationName': locationName,
      'country' : country,
      'state' : state,
      'city' : city,
      'county' : county,
      'longitude': longitude,
      'latitude': latitude,
      'fromTime': fromTime,
      'toTime': toTime,
      'isBusinessAccount': isBusinessAccount,
      'biography': biography,
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      nickName: nickName,
      phoneNumber: phoneNumber,
      isBusinessAccount: isBusinessAccount,
      isGrantedForPreciseLocation: isGrantedForPreciseLocation ?? false,
      longitude: longitude,
      latitude: latitude,
      fromTime: fromTime,
      locationName: locationName,
      toTime: toTime,
      biography : biography,
    );
  }
}
