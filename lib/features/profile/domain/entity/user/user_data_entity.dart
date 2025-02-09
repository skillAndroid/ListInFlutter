class UserDataEntity {
  final String id;
  final String? nickName;
  final bool enableCalling;
  final String? phoneNumber;
  final String? fromTime;
  final String? toTime;
  final String? email;
  final String? profileImagePath;
  final double rating;
  final bool? isGrantedForPreciseLocation;
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

  UserDataEntity({
    required this.id,
    this.nickName,
    required this.enableCalling,
    this.phoneNumber,
    this.fromTime,
    this.toTime,
    this.email,
    this.profileImagePath,
    required this.rating,
    this.isGrantedForPreciseLocation,
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
  });

  UserDataEntity copyWith({
    String? id,
    String? nickName,
    bool? enableCalling,
    String? phoneNumber,
    String? fromTime,
    String? toTime,
    String? email,
    String? profileImagePath,
    double? rating,
    bool? isGrantedForPreciseLocation,
    String? locationName,
    double? longitude,
    double? latitude,
    String? role,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    int? following,
    int? followers,
    bool? isFollowing,
    String? biography,
  }) {
    return UserDataEntity(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      enableCalling: enableCalling ?? this.enableCalling,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      rating: rating ?? this.rating,
      isGrantedForPreciseLocation:
          isGrantedForPreciseLocation ?? this.isGrantedForPreciseLocation,
      locationName: locationName ?? this.locationName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      role: role ?? this.role,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      isFollowing: isFollowing ?? this.isFollowing,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      biography: biography ?? this.biography,
    );
  }
}
