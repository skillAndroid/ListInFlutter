import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/sources/catalog_remote_data_source.dart';
import 'package:list_in/features/post/data/sources/category_local_data_source.dart';
import 'package:list_in/features/post/domain/repository/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;
  final CatalogLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CatalogRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryModel>>> getCatalogs() async {
    try {
      if (await localDataSource.hasCachedData()) {
        final localCatalogs = await localDataSource.getCachedCategories();

        return Right(localCatalogs);
      }

      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteCatalogs = await remoteDataSource.getCatalogs();

          await localDataSource.cacheCatalogs(remoteCatalogs);

          return Right(remoteCatalogs);
        } catch (e) {
          rethrow;
        }
      } else {
        return Left(NetworkFailure());
      }
    } on ServerExeption {
      return Left(ServerFailure());
    } on CacheExeption {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
