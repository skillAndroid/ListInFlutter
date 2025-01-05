import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/sources/post_remote_data_source.dart';
import 'package:list_in/features/post/data/sources/post_local_data_source.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final CatalogRemoteDataSource remoteDataSource;
  final CatalogLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
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

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images) async {
    if (await networkInfo.isConnected) {
      try {
        final listOfImages = await remoteDataSource.uploadImages(images);
        debugPrint("This is the REPOSITORY_IMAGES : $listOfImages");
        return Right(listOfImages);
      } on ServerExeption {
        debugPrint("Here is ther error Server Exeption");
        return Left(ServerFailure());
      } on ConnectiontTimeOutExeption {
        debugPrint("Here is ther error  ConnectiontTimeOutExeption");
        return Left(NetworkFailure());
      } catch (e) {
        debugPrint("Here is ther error $e");
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideo(XFile video) async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.uploadVideo(video);
        return Right(url);
      } on ServerExeption {
        return Left(ServerFailure());
      } on ConnectiontTimeOutExeption {
        return Left(NetworkFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createPost(PostEntity post) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createPost(post.toModel());
        return Right(result);
      } on ServerExeption {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
