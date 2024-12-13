import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';
import 'package:list_in/features/auth/domain/usecases/get_stored_email_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/login_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/register_user_data.dart';
import 'package:list_in/features/auth/domain/usecases/signup_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/verify_email_signup.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailSignupUseCase verifyEmailSignupUseCase;
  final RegisterUserDataUseCase registerUserDataUseCase;
  final GetStoredEmailUsecase getStoredEmailUsecase;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.verifyEmailSignupUseCase,
    required this.registerUserDataUseCase,
    required this.getStoredEmailUsecase,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<EmailVerificationSubmitted>(_onVerifyEmailSignupSubmitted);
    on<RegisterUserDataSubmitted>(_onRegisterUserDataSubmitted);
    on<InputChanged>(_onInputChanged);
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
    emit(AuthLoading());

    final storedEmailResult = await getStoredEmailUsecase();

    if (storedEmailResult == null || storedEmailResult.email == null) {
      emit(AuthSignUpError(message: 'Stored email not found'));
      return;
    }

    final result = await registerUserDataUseCase(
      params: User(
        nikeName: event.nikeName,
        phoneNumber: event.phoneNumber,
        email: storedEmailResult.email!,
        password: event.password,
        locationName: event.locationName,
        isGrantedForPreciseLocation: event.isGrantedForPreciseLocation,
        lotitude: event.lotitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) =>
          emit(AuthSignUpError(message: _mapFailureToMessage(failure))),
      (authToken) => emit(RegistrationUserSuccess(authToken: authToken)),
    );
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

  void _onInputChanged(InputChanged event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server Error';
      case NetworkFailure _:
        return 'Network Error';
      default:
        return 'Unexpected Error';
    }
  }
}
