// auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthToken authToken;
  AuthSuccess({required this.authToken});
}

class RegistrationUserSuccess extends AuthState {
  final AuthToken authToken;
  RegistrationUserSuccess({required this.authToken});
}

class SignupSuccess extends AuthState {}

class VerificationSuccess extends AuthState {}

class EmailReceivedSuccess extends AuthState {}


class AuthVerificationError extends AuthState {
  final String message;
  AuthVerificationError({required this.message});
}

class AuthLoginError extends AuthState {
  final String message;
  AuthLoginError({required this.message});
}

class AuthSignUpError extends AuthState {
  final String message;
  AuthSignUpError({required this.message});
}
