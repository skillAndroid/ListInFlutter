import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/data/models/category.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<Category>>> getCatalogs();
}
