import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

// Modify the VerifyEmailSignupUseCase to handle getting the stored email
class VerifyEmailSignupUseCase implements UseCase<Either<Failure, void>, VerifyEmail> {
  final AuthRepository repository;

  VerifyEmailSignupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call({VerifyEmail? params}) async {
    if (params == null) return Left(ServerFailure());
    
    // Get the stored email first
    final storedEmail = await repository.getStoredEmail();
    if (storedEmail == null) {
      return Left(ServerFailure());
    }

    // Create new VerifyEmail with stored email and provided code
    final verifyEmail = VerifyEmail(
      email: storedEmail.email,
      code: params.code,
    );

    return repository.verifyEmailSignup(verifyEmail);
  }
}