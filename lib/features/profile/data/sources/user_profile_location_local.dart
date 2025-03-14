import 'dart:convert';

import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUserLocation({
    required Country? country,
    required State? state,
    required County? county,
    double? longitude,
    double? latitude,
    bool? isGrantedForPreciseLocation,
    String? locationName,
  });

  Future<Map<String, dynamic>?> getUserLocation();
}

class UserProfileLocationLocalImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;
  UserProfileLocationLocalImpl({required this.sharedPreferences});
  @override
  Future<void> cacheUserLocation({
    required Country? country,
    required State? state,
    required County? county,
    double? longitude,
    double? latitude,
    bool? isGrantedForPreciseLocation,
    String? locationName,
  }) async {
    if (country != null) {
      final countryJson = {
        'id': country.countryId,
        'value': country.value,
        'valueUz': country.valueUz,
        'valueRu': country.valueRu,
      };
      await sharedPreferences.setString(
        Constants.CACHED_USER_COUNTRY,
        json.encode(countryJson),
      );
    }

    if (state != null) {
      final stateJson = {
        'id': state.stateId,
        'value': state.value,
        'valueUz': state.valueUz,
        'valueRu': state.valueRu,
      };
      await sharedPreferences.setString(
        Constants.CACHED_USER_STATE,
        json.encode(stateJson),
      );
    }

    if (county != null) {
      final countyJson = {
        'id': county.countyId,
        'value': county.value,
        'valueUz': county.valueUz,
        'valueRu': county.valueRu,
      };
      await sharedPreferences.setString(
        Constants.CACHED_USER_COUNTY,
        json.encode(countyJson),
      );
    }

    final locationDetailsJson = {
      'longitude': longitude ?? 0,
      'latitude': latitude ?? 0,
      'isGrantedForPreciseLocation': isGrantedForPreciseLocation ?? false,
      'locationName': locationName ?? '',
    };

    await sharedPreferences.setString(
      Constants.CACHED_USER_LOCATION_DETAILS,
      json.encode(locationDetailsJson),
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserLocation() async {
    // Get stored location data
    final countryJson =
        sharedPreferences.getString(Constants.CACHED_USER_COUNTRY);
    final stateJson = sharedPreferences.getString(Constants.CACHED_USER_STATE);
    final countyJson =
        sharedPreferences.getString(Constants.CACHED_USER_COUNTY);
    final locationDetailsJson =
        sharedPreferences.getString(Constants.CACHED_USER_LOCATION_DETAILS);

    if (countryJson == null &&
        stateJson == null &&
        countyJson == null &&
        locationDetailsJson == null) {
      return null;
    }

    // Parse stored data
    final Map<String, dynamic> locationData = {};

    if (countryJson != null) {
      locationData['country'] = json.decode(countryJson);
    }

    if (stateJson != null) {
      locationData['state'] = json.decode(stateJson);
    }

    if (countyJson != null) {
      locationData['county'] = json.decode(countyJson);
    }

    if (locationDetailsJson != null) {
      final details = json.decode(locationDetailsJson);
      locationData['longitude'] = details['longitude'];
      locationData['latitude'] = details['latitude'];
      locationData['isGrantedForPreciseLocation'] =
          details['isGrantedForPreciseLocation'];
      locationData['locationName'] = details['locationName'];
    }
    return locationData;
  }

  Future<void> clearUserLocation() async {
    await sharedPreferences.remove(Constants.CACHED_USER_COUNTRY);
    await sharedPreferences.remove(Constants.CACHED_USER_STATE);
    await sharedPreferences.remove(Constants.CACHED_USER_COUNTY);
    await sharedPreferences.remove(Constants.CACHED_USER_LOCATION_DETAILS);
  }
}
