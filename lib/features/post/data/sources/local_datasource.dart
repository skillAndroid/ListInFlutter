
// // Catalog data model for Hive
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';

// @HiveType(typeId: 0)
// class CatalogData extends HiveObject {
//   @HiveField(0)
//   late String jsonData;

//   @HiveField(1)
//   late String version;
// }

// class CatalogStorageService {
//   static const String _catalogBoxName = 'catalogBox';
//   static const String _catalogKey = 'catalogData';

//   // Initialize Hive
//   static Future<void> initializeHive() async {
//     await Hive.initFlutter();
//     Hive.registerAdapter(CatalogDataAdapter());
    
//     // Open the catalog box
//     await Hive.openBox<CatalogData>(_catalogBoxName);
//   }

//   // Save catalog data with version
//   static Future<void> saveCatalog(String jsonString, String version) async {
//     final box = Hive.box<CatalogData>(_catalogBoxName);
    
//     final catalogData = CatalogData()
//       ..jsonData = jsonString
//       ..version = version;
    
//     await box.put(_catalogKey, catalogData);
//   }

//   // Load catalog data
//   static Future<Map<String, dynamic>?> loadCatalog() async {
//     final box = Hive.box<CatalogData>(_catalogBoxName);
//     final catalogData = box.get(_catalogKey);
    
//     if (catalogData != null) {
//       return json.decode(catalogData.jsonData);
//     }
//     return null;
//   }

//   // Check if catalog needs update
//   static Future<bool> shouldUpdateCatalog(String newVersion) async {
//     final box = Hive.box<CatalogData>(_catalogBoxName);
//     final currentCatalog = box.get(_catalogKey);
    
//     return currentCatalog == null || currentCatalog.version != newVersion;
//   }

//   // Clear catalog data
//   static Future<void> clearCatalog() async {
//     final box = Hive.box<CatalogData>(_catalogBoxName);
//     await box.delete(_catalogKey);
//   }
// }

// // Usage example in your main app or service
// class CatalogService {
//   Future<void> fetchAndStoreCatalog() async {
//     try {
//       // Simulated API call to get catalog
//       String jsonString = '...'; // Your JSON string
//       String newVersion = '1.0.0'; // Version from API or server

//       // Check if update is needed
//       if (await CatalogStorageService.shouldUpdateCatalog(newVersion)) {
//         // Save new catalog data
//         await CatalogStorageService.saveCatalog(jsonString, newVersion);
//       }

//       // Load catalog (either new or existing)
//       final catalogData = await CatalogStorageService.loadCatalog();
      
//       // Process catalog data...
//     } catch (e) {
//       print('Error fetching catalog: $e');
//     }
//   }
// }