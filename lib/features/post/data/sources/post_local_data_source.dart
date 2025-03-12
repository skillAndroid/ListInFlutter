import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';

abstract class CatalogLocalDataSource {
  Future<List<CategoryModel>> getCachedCategories();
  Future<List<Country>> getCachedLocations();
  Future<void> cacheCatalogs(List<CategoryModel> catalogs);
  Future<void> cacheLocations(List<Country> locations);
  Future<bool> hasCachedCategoriesData();
  Future<bool> hasCachedLocationsData();
}

class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  final Box<CategoryModel> categoryBox;
  final Box<Country> locationBox;

  CatalogLocalDataSourceImpl(
      {required this.categoryBox, required this.locationBox});

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
  Future<bool> hasCachedCategoriesData() async {
    try {
      final hasData = categoryBox.isNotEmpty;
      debugPrint("😤😤 Success in has cashe catalogs");
      return hasData;
    } catch (e) {
      debugPrint("😤😤 Failed in has chashe catalogs : $e");
      throw CacheExeption(message: 'Failed to check cached data');
    }
  }

  @override
  Future<bool> hasCachedLocationsData() async {
    try {
      final hasData = locationBox.isNotEmpty;
      debugPrint("😤😤 Success in has cashe locations");
      return hasData;
    } catch (e) {
      debugPrint("😤😤 Failed in has chashe locations : $e");
      throw CacheExeption(message: 'Failed to check cached data');
    }
  }

  @override
  Future<List<Country>> getCachedLocations() async {
    try {
      final locations = locationBox.values.toList();

      return locations;
    } catch (e) {
      throw CacheExeption(message: 'Failed to get cached locations');
    }
  }

  @override
  Future<void> cacheLocations(List<Country> locations) async {
    try {
      await locationBox.clear();
      debugPrint("😤😤 Success in cashe locations");
      await locationBox.addAll(locations);
    } catch (e) {
      debugPrint("😤😤 Failed in cashe locations : $e");
      throw CacheExeption(message: 'Failed to cache locations');
    }
  }
}
