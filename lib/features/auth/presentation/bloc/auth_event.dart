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
  final String roles;
  final String locationName;
  final double lotitude;
  final double longitude;
  final bool isGrantedForPreciseLocation;
  RegisterUserDataSubmitted({
    required this.nikeName,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.roles,
    required this.locationName,
    required this.isGrantedForPreciseLocation,
    required this.longitude,
    required this.lotitude,
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
