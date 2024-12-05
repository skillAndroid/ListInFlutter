import 'package:dartz/dartz.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<Either, Login> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  @override
  Future<Either> call({Login? params}) async {
    return await repository.login(params!);
  }
}
