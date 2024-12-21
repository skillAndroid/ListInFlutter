import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/post/data/models/category.dart';
import 'package:list_in/features/post/domain/repository/catalog_repository.dart';

class GetCatalogs implements UseCase2<List<Category>, NoParams> {
  final CatalogRepository repository;

  GetCatalogs(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call({NoParams? params}) async {
    return await repository.getCatalogs();
  }
}
