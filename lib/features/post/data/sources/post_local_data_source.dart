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
  final Box<dynamic> metaBox;

  CatalogLocalDataSourceImpl({
    required this.categoryBox,
    required this.locationBox,
    required this.metaBox,
  });
  Future<void> initialize() async {
    try {
      const currentCategoryVersion = 3;
      const currentLocationVersion = 1;

      final storedCategoryVersion =
          metaBox.get('category_schema_version', defaultValue: 0);
      final storedLocationVersion =
          metaBox.get('location_schema_version', defaultValue: 0);

      // Handle category schema changes
      if (storedCategoryVersion < currentCategoryVersion) {
        debugPrint("Schema version changed for categories, clearing old data");
        try {
          await categoryBox.clear();
          await metaBox.put('category_schema_version', currentCategoryVersion);
        } catch (e) {
          debugPrint("Error during category schema migration: $e");
          // Consider a more robust recovery strategy here
        }
      }

      // Handle location schema changes
      if (storedLocationVersion < currentLocationVersion) {
        debugPrint("Schema version changed for locations, clearing old data");
        try {
          await locationBox.clear();
          await metaBox.put('location_schema_version', currentLocationVersion);
        } catch (e) {
          debugPrint("Error during location schema migration: $e");
          // Consider a more robust recovery strategy here
        }
      }
    } catch (e) {
      debugPrint("Critical error during initialization: $e");
      // Fallback implementation
    }
  }

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
