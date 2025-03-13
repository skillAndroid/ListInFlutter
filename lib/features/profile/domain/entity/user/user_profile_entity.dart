class UserProfileEntity {
  final String? profileImagePath;
  final String? nickName;
  final String? phoneNumber;
  final bool? isGrantedForPreciseLocation;
  final String? locationName;
  final double? longitude;
  final double? latitude;
  final String? city;
  final String? country;
  final String? county;
  final String? state;
  final String? fromTime;
  final String? toTime;
  final bool? isBusinessAccount;
  final String? biography;

  UserProfileEntity({
    this.profileImagePath,
    this.nickName,
    this.phoneNumber,
    this.isGrantedForPreciseLocation,
    this.locationName,
    this.country,
    this.state,
    this.city,
    this.county,
    this.longitude,
    this.latitude,
    this.fromTime,
    this.toTime,
    this.isBusinessAccount,
    this.biography,
  });

  UserProfileEntity copyWith({
    String? nickName,
    String? phoneNumber,
    bool? isBusinessAccount,
    bool? isGrantedForPreciseLocation,
    String? profileImagePath,
    String? fromTime,
    String? toTime,
    double? longitude,
    double? latitude,
    String? locationName,
    String? biography,
    String? country,
    String? county,
    String? state,
  }) {
    return UserProfileEntity(
      nickName: nickName ?? this.nickName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isBusinessAccount: isBusinessAccount ?? this.isBusinessAccount,
      isGrantedForPreciseLocation:
          isGrantedForPreciseLocation ?? this.isGrantedForPreciseLocation,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      locationName: locationName ?? this.locationName,
      biography: biography ?? this.biography,
      country: country ?? this.country,
      state: state ?? this.state,
      county: county ?? this.county,
    );
  }
}
