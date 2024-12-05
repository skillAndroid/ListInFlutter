import 'package:dartz/dartz.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase implements UseCase<Either, Signup> {
  final AuthRepository repository;
  SignupUseCase(this.repository);
  @override
  Future<Either> call({Signup? params}) async {
    return await repository.signup(params!);
  }
}