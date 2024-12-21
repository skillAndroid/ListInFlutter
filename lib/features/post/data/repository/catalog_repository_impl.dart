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
      print('Starting getCatalogs in repository...');
      
      // Check for cached data
      if (await localDataSource.hasCachedData()) {
        print('Found cached data, retrieving...');
        final localCatalogs = await localDataSource.getCachedCategories();
        print('Successfully retrieved ${localCatalogs.length} cached catalogs');
        return Right(localCatalogs);
      }

      // Check network connection
      final isConnected = await networkInfo.isConnected;
      print('Network connection status: $isConnected');

      if (isConnected) {
        try {
          print('Fetching catalogs from remote...');
          final remoteCatalogs = await remoteDataSource.getCatalogs();
          print('Successfully fetched ${remoteCatalogs.length} catalogs from remote');

          // Cache the new data
          print('Caching remote catalogs...');
          await localDataSource.cacheCatalogs(remoteCatalogs);
          print('Successfully cached remote catalogs');

          return Right(remoteCatalogs);
        } catch (e) {
          print('Error fetching/caching remote catalogs: $e');
          throw e;
        }
      } else {
        print('No network connection available');
        return Left(NetworkFailure());
      }
    } on ServerExeption catch (e) {
      print('Server exception caught: ${e.message}');
      return Left(ServerFailure());
    } on CacheExeption catch (e) {
      print('Cache exception caught: ${e.message}');
      return Left(CacheFailure());
    } catch (e) {
      print('Unexpected error caught: $e');
      return Left(UnexpectedFailure());
    }
  }
}
