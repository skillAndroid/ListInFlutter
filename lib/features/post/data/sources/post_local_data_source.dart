import 'package:flutter/material.dart';
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
      final categories = categoryBox.values.toList();

      return categories;
    } catch (e) {
      throw CacheExeption(message: 'Failed to get cached categories');
    }
  }

  @override
  Future<void> cacheCatalogs(List<CategoryModel> catalogs) async {
    try {
      await categoryBox.clear();
      debugPrint("😤😤 Success in cashe catalogs");
      await categoryBox.addAll(catalogs);
    } catch (e) {
      debugPrint("😤😤 Failed in cashe catalogs : $e");
      throw CacheExeption(message: 'Failed to cache categories');
    }
  }

  @override
  Future<bool> hasCachedData() async {
    try {
      final hasData = categoryBox.isNotEmpty;
      debugPrint("😤😤 Success in has cashe catalogs");
      return hasData;
    } catch (e) {
      debugPrint("😤😤 Failed in has chashe catalogs : $e");
      throw CacheExeption(message: 'Failed to check cached data');
    }
  }
}
