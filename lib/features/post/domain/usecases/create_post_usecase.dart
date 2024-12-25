import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class CreatePostUseCase implements UseCase2<String, PostEntity> {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call({PostEntity? params}) async {
    if (params == null) return Left(ValidationFailure());
    return await repository.createPost(params);
  }
}
