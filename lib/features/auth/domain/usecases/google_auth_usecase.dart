import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';

import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

// Create a data class for the parameters
class GoogleAuthParams {
  final String idToken;
  final String email;

  GoogleAuthParams({
    required this.idToken,
    required this.email,
  });
}

class GoogleAuthUseCase
    implements UseCase<Either<Failure, AuthToken>, GoogleAuthParams> {
  final AuthRepository repository;

  GoogleAuthUseCase(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call({GoogleAuthParams? params}) async {
    return await repository.googleAuth(params!.idToken, params.email);
  }
}
