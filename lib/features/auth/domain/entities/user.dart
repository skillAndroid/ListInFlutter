class User {
  final String nikeName;
  final String phoneNumber;
  final String email;
  final String password;
  final String roles;
  final String locationName;
  final String? city;
  final String? country;
  final String? county;
  final String? state;
  final double latitude;
  final double longitude;
  final bool isGrantedForPreciseLocation;
  
  User({
    required this.nikeName,
    required this.phoneNumber,
    required this.city,
    required this.country,
    required this.county,
    required this.state,
    required this.email,
    required this.password,
    required this.locationName,
    required this.isGrantedForPreciseLocation,
    required this.longitude,
    required this.latitude,
    required this.roles,
  });
}
