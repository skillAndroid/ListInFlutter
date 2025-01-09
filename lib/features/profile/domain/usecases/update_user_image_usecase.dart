import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

class UploadUserImagesUseCase extends UseCase2<List<String>, List<XFile>> {
  final UserProfileRepository repository;

  UploadUserImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call({List<XFile>? params}) async {
    if (params == null) return Left(ValidationFailure());
    return await repository.uploadImages(params);
  }
}