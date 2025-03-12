// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/post/data/sources/post_remote_data_source.dart';
import 'package:list_in/features/post/data/sources/post_local_data_source.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final CatalogRemoteDataSource remoteDataSource;
  final CatalogLocalDataSource localDataSource;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    try {
      print("🔍 Проверяем кэшированные данные...");
      if (await localDataSource.hasCachedCategoriesData()) {
        final localCatalogs = await localDataSource.getCachedCategories();
        print("✅ Данные найдены в кэше. Возвращаем локальные данные.");
        return Right(localCatalogs);
      }

      print("🌐 Проверяем подключение к интернету...");

      try {
        print("📡 Запрашиваем данные с сервера...");
        final remoteCatalogs = await remoteDataSource.getCatalogs();

        print("💾 Кэшируем полученные данные...");
        await localDataSource.cacheCatalogs(remoteCatalogs);

        print("✅ Данные успешно загружены с сервера и закэшированы.");
        return Right(remoteCatalogs);
      } catch (e) {
        print("❌ Ошибка при получении данных с сервера: $e");
        rethrow;
      }
    } on ServerExeption {
      print("🛑 Ошибка сервера! Возвращаем ServerFailure.");
      return Left(ServerFailure());
    } on CacheExeption {
      print("🗄️ Ошибка кэша! Возвращаем CacheFailure.");
      return Left(CacheFailure());
    } catch (e) {
      print("❓ Непредвиденная ошибка: $e. Возвращаем UnexpectedFailure.");
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images) async {
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
  }

  @override
  Future<Either<Failure, String>> uploadVideo(XFile video) async {
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
  }

  @override
  Future<Either<Failure, String>> createPost(PostEntity post) async {
    try {
      final result = await remoteDataSource.createPost(post.toModel());
      return Right(result);
    } on ServerExeption {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getLocationTree() async {
    try {
      print("🔍 Проверяем кэшированные данные...");
      if (await localDataSource.hasCachedLocationsData()) {
        final locationTree = await localDataSource.getCachedLocations();
        print("✅ Данные найдены в кэше. Возвращаем локальные данные.");
        return Right(locationTree);
      }

      print("🌐 Проверяем подключение к интернету...");

      try {
        print("📡 Запрашиваем данные с сервера...");
        final remoteCatalogs = await remoteDataSource.getLocations();

        print("💾 Кэшируем полученные данные...");
        await localDataSource.cacheLocations(remoteCatalogs);

        print("✅ Данные успешно загружены с сервера и закэшированы.");
        return Right(remoteCatalogs);
      } catch (e) {
        print("❌ Ошибка при получении данных с сервера: $e");
        rethrow;
      }
    } on ServerExeption {
      print("🛑 Ошибка сервера! Возвращаем ServerFailure.");
      return Left(ServerFailure());
    } on CacheExeption {
      print("🗄️ Ошибка кэша! Возвращаем CacheFailure.");
      return Left(CacheFailure());
    } catch (e) {
      print("❓ Непредвиденная ошибка: $e. Возвращаем UnexpectedFailure.");
      return Left(UnexpectedFailure());
    }
  }
}
