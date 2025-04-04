import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';
import 'package:list_in/features/auth/domain/usecases/get_stored_email_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/login_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/register_user_data.dart';
import 'package:list_in/features/auth/domain/usecases/signup_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/verify_email_signup.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailSignupUseCase verifyEmailSignupUseCase;
  final RegisterUserDataUseCase registerUserDataUseCase;
  final GetStoredEmailUsecase getStoredEmailUsecase;
  final GoogleAuthUseCase googleAuthUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.verifyEmailSignupUseCase,
    required this.registerUserDataUseCase,
    required this.getStoredEmailUsecase,
    required this.googleAuthUseCase,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<EmailVerificationSubmitted>(_onVerifyEmailSignupSubmitted);
    on<RegisterUserDataSubmitted>(_onRegisterUserDataSubmitted);
    on<InputChanged>(_onInputChanged);
    on<GoogleAuthSubmitted>(_onGoogleAuthSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      params: Login(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthLoginError(message: _mapFailureToMessage(failure))),
      (authToken) => emit(AuthSuccess(authToken: authToken)),
    );
  }

  Future<void> _onRegisterUserDataSubmitted(
    RegisterUserDataSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final storedEmailResult = await getStoredEmailUsecase();

      if (storedEmailResult?.email == null) {
        emit(const AuthError(
          message: 'Stored email not found',
          type: AuthErrorType.registration,
        ));
        return;
      }

      final result = await registerUserDataUseCase(
        params: User(
          nikeName: event.nikeName,
          phoneNumber: event.phoneNumber,
          email: storedEmailResult!.email!,
          password: event.password,
          locationName: event.locationName,
          country: event.country,
          state: event.state,
          city: event.city,
          county: event.county,
          isGrantedForPreciseLocation: event.isGrantedForPreciseLocation,
          latitude: event.latitude,
          longitude: event.longitude,
          roles: event.userType == UserType.individualSeller
              ? 'INDIVIDUAL_SELLER'
              : 'BUSINESS_SELLER',
        ),
      );

      result.fold(
        (failure) => emit(AuthError(
          message: _mapFailureToMessage(failure),
          type: AuthErrorType.registration,
        )),
        (authToken) => emit(RegistrationUserSuccess(authToken: authToken)),
      );
    } catch (e) {
      emit(AuthError(
        message: 'An unexpected error occurred',
        type: AuthErrorType.registration,
      ));
    }
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signupUseCase(params: Signup(email: event.email));

    result.fold(
      (failure) =>
          emit(AuthSignUpError(message: _mapFailureToMessage(failure))),
      (_) => emit(EmailReceivedSuccess()),
    );
  }

  Future<void> _onVerifyEmailSignupSubmitted(
    EmailVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyEmailSignupUseCase(
      params: VerifyEmail(code: event.verificationCode),
    );

    result.fold(
      (failure) =>
          emit(AuthVerificationError(message: _mapFailureToMessage(failure))),
      (_) => emit(VerificationSuccess()),
    );
  }

  Future<void> _onGoogleAuthSubmitted(
    GoogleAuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Show loading state
    emit(AuthLoading());

    // Try to authenticate with the server
    final result = await googleAuthUseCase(
      params: GoogleAuthParams(
        idToken: event.idToken,
        email: event.email,
      ),
    );

    // Handle the result
    result.fold(
      // If authentication fails or needs registration
      (failure) {
        if (failure is RegistrationNeededFailure) {
          // Special case: User needs to register, navigating to registration page
          emit(GoogleUserNeedsRegistration(email: event.email));
        } else if (failure is ValidationFailure) {
          // Authentication validation error
          emit(AuthLoginError(message: _mapFailureToMessage(failure)));
        } else {
          // Other authentication error
          emit(AuthLoginError(message: _mapFailureToMessage(failure)));
        }
      },
      // If authentication succeeds
      (authToken) {
        // User successfully authenticated
        emit(AuthSuccess(authToken: authToken));
      },
    );
  }

  void _onInputChanged(InputChanged event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure error:
        return '$error';
      case NetworkFailure error:
        return '$error';
      case CacheFailure error:
        return '$error';
      case ValidationFailure error:
        return '$error';
      case UnexpectedFailure _:
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
