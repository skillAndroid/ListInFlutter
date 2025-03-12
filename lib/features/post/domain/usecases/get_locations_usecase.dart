import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class GetLocationsUsecase implements UseCase2<List<Country>, NoParams> {
  final PostRepository repository;

  GetLocationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Country>>> call({NoParams? params}) async {
    return await repository.getLocationTree();
  }
}
