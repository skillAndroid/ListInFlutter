import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class GetGategoriesUsecase implements UseCase2<List<CategoryModel>, NoParams> {
  final PostRepository repository;

  GetGategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<CategoryModel>>> call({NoParams? params}) async {
    return await repository.getCategories();
  }
}
