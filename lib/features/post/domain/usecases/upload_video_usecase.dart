import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class UploadVideoUseCase implements UseCase2<String, XFile> {
  final PostRepository repository;

  UploadVideoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call({XFile? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }
    return await repository.uploadVideo(params);
  }
}
