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
  });
}