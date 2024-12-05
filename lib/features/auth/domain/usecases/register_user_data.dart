import 'package:dartz/dartz.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserDataUseCase implements UseCase<Either, User> {
  final AuthRepository repository;
  RegisterUserDataUseCase(this.repository);
  @override
  Future<Either> call({User? params}) async {
    return await repository.registerUserData(params!);
  }
}
