// auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

class RegisterUserDataSubmitted extends AuthEvent {
  final String nikeName;
  final String phoneNumber;
  final String? email;
  final String password;
  final String locationName;
  final double latitude;
  final double longitude;
  final bool isGrantedForPreciseLocation;
  final UserType userType;
  RegisterUserDataSubmitted({
    required this.nikeName,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.locationName,
    required this.isGrantedForPreciseLocation,
    required this.longitude,
    required this.latitude,
    required this.userType,
  });
}

class SignupSubmitted extends AuthEvent {
  final String email;
  SignupSubmitted({required this.email});
}

class EmailVerificationSubmitted extends AuthEvent {
  final String verificationCode;
  EmailVerificationSubmitted({required this.verificationCode});
}

class InputChanged extends AuthEvent {}

enum UserType { individualSeller, storeSeller }
abstract class RegistrationEvent {}
class UpdateNikeName extends RegistrationEvent {
  final String nikeName;
  UpdateNikeName(this.nikeName);
}

class UpdatePhoneNumber extends RegistrationEvent {
  final String phoneNumber;
  UpdatePhoneNumber(this.phoneNumber);
}

class UpdatePassword extends RegistrationEvent {
  final String password;
  UpdatePassword(this.password);
}

class UpdateLocation extends RegistrationEvent {
  final LocationEntity location;
  UpdateLocation(this.location);
}

class UpdateUserType extends RegistrationEvent {
  final UserType userType;
  UpdateUserType(this.userType);
}

