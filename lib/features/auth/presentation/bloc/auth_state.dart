// auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserDataDtoEntity user;
  const AuthSuccess({required this.user});
}

class RegistrationUserSuccess extends AuthState {
  final UserDataDtoEntity user;
  const RegistrationUserSuccess({required this.user});
}

class SignupSuccess extends AuthState {}

class VerificationSuccess extends AuthState {
  const VerificationSuccess();
}

class AuthError extends AuthState {
  final String message;
  final AuthErrorType type;

  const AuthError({
    required this.message,
    required this.type,
  });
}

enum AuthErrorType { login, signup, verification, registration }

class EmailReceivedSuccess extends AuthState {
  const EmailReceivedSuccess();
}

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

class GoogleUserNeedsRegistration extends AuthState {
  final String email;

  const GoogleUserNeedsRegistration({required this.email});
}
