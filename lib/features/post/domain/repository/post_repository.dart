import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<CategoryModel>>> getCategories();
  Future<Either<Failure, List<Country>>> getLocationTree();
  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images);
  Future<Either<Failure, String>> uploadVideo(XFile video);
  Future<Either<Failure, String>> createPost(PostEntity post);
}
