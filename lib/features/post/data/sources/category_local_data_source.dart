import 'package:hive/hive.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/features/post/data/models/category_model.dart';

abstract class CatalogLocalDataSource {
  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCatalogs(List<CategoryModel> catalogs);
  Future<bool> hasCachedData();
}
class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  final Box<CategoryModel> categoryBox;
  
  CatalogLocalDataSourceImpl({required this.categoryBox});

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    try {
      print('Getting cached categories...');
      final categories = categoryBox.values.toList();
      print('Found ${categories.length} cached categories');
      return categories;
    } catch (e) {
      print('Error getting cached categories: $e');
      throw CacheExeption(message: 'Failed to get cached categories');
    }
  }

  @override
  Future<void> cacheCatalogs(List<CategoryModel> catalogs) async {
    try {
      print('Caching ${catalogs.length} categories...');
      await categoryBox.clear();
      await categoryBox.addAll(catalogs);
      print('Successfully cached categories');
    } catch (e) {
      print('Error caching categories: $e');
      throw CacheExeption(message: 'Failed to cache categories');
    }
  }

  @override
  Future<bool> hasCachedData() async {
    try {
      final hasData = categoryBox.isNotEmpty;
      print('Checking cached data. Has data: $hasData');
      return hasData;
    } catch (e) {
      print('Error checking cached data: $e');
      throw CacheExeption(message: 'Failed to check cached data');
    }
  }
}