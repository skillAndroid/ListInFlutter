class User {
  final String firstname;
  final String lastname;
  final int age;
  final String phoneNumber;
  final String email;
  final String password;
  final String roles;

  User({
    required this.firstname,
    required this.lastname,
    required this.age,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.roles = "USER",
  });
}
