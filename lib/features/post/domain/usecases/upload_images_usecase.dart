import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class UploadImagesUseCase implements UseCase2<List<String>, List<XFile>> {
  final PostRepository repository;

  UploadImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call({List<XFile>? params}) async {
    if (params == null) {
      return Left(ServerFailure());
    }
    return await repository.uploadImages(params);
  }
}
