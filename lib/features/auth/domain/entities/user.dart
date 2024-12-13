class User {
  final String nikeName;
  final String phoneNumber;
  final String email;
  final String password;
  final String roles;
  final String locationName;
  final double lotitude;
  final double longitude;
  final bool isGrantedForPreciseLocation;

  User({
    required this.nikeName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.locationName,
    required this.isGrantedForPreciseLocation,
    required this.longitude,
    required this.lotitude,
    this.roles = "USER",
  });
}
