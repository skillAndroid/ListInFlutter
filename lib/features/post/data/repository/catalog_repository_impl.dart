import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/post/data/models/category.dart';
import 'package:list_in/features/post/data/sources/catalog_remote_data_source.dart';
import 'package:list_in/features/post/domain/repository/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add network info

  CatalogRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Category>>> getCatalogs() async {
    if (await networkInfo.isConnected) {
      try {
        final catalogs = await remoteDataSource.getCatalogs();
        return Right(catalogs);
      } on ServerExeption {
        return Left(ServerFailure());
      } on ConnectionExeption {
        return Left(NetworkFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
