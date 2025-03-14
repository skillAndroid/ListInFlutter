import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';

// fot updating the user data is correct!
class UserDataModelForUpdate {
  final String? profileImagePath;
  final String? nickName;
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

  UserDataModelForUpdate({
    this.profileImagePath,
    this.nickName,
    this.phoneNumber,
    this.isGrantedForPreciseLocation,
    this.locationName,
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

  Map<String, dynamic> toJson() {
    return {
      'profileImagePath': profileImagePath,
      'nickName': nickName,
      'phoneNumber': phoneNumber,
      'isGrantedForPreciseLocation': isGrantedForPreciseLocation,
      'locationName': locationName,
      'country': country,
      'state': state,
      'county': county,
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
      biography: biography,
      country: country,
      state: state,
      county: county,
    );
  }
}
