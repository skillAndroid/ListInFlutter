// auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

class RegisterUserDataSubmitted extends AuthEvent {
  final String firstname;
  final String lastname;
  final int age;
  final String phoneNumber;
  final String? email;
  final String password;
  final String roles;
  RegisterUserDataSubmitted({
    required this.firstname,
    required this.lastname,
    required this.age,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.roles,
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
