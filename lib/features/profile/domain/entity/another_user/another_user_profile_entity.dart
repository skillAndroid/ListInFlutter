class AnotherUserProfileEntity {
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

  AnotherUserProfileEntity({
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

  AnotherUserProfileEntity copyWith({
    String? id,
    String? nickName,
    bool? enableCalling,
    String? phoneNumber,
    String? biography,
    String? fromTime,
    String? toTime,
    String? email,
    String? profileImagePath,
    num? rating,
    bool? isGrantedForPreciseLocation,
    String? locationName,
    double? longitude,
    int? followers,
    int? following,
    bool? isFollowing,
    double? latitude,
    String? role,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) {
    return AnotherUserProfileEntity(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      enableCalling: enableCalling ?? this.enableCalling,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      biography: biography ?? this.biography,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      rating: rating ?? this.rating,
      isGrantedForPreciseLocation: 
        isGrantedForPreciseLocation ?? this.isGrantedForPreciseLocation,
      locationName: locationName ?? this.locationName,
      longitude: longitude ?? this.longitude,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isFollowing: isFollowing ?? this.isFollowing,
      latitude: latitude ?? this.latitude,
      role: role ?? this.role,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }
}