import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:list_in/features/map/service/models.dart';

abstract class AppLocation {
  Future<AppLatLong> getCurrentLocation();

  Future<bool> requestPermission();

  Future<bool> checkPermission();
}

class LocationService implements AppLocation {
  final defLocation = const MoscowLocation();
  AppLatLong? _cachedLocation;
  
  @override
  Future<AppLatLong> getCurrentLocation() async {
    if (_cachedLocation != null) {
      debugPrint('Returning cached location: $_cachedLocation');
      return _cachedLocation!;
    }

    try {
      debugPrint('Requesting current location...');
      final position = await Geolocator.getCurrentPosition();
      _cachedLocation = AppLatLong(lat: position.latitude, long: position.longitude);
      debugPrint('Location fetched: $_cachedLocation');
      return _cachedLocation!;
    } catch (error) {
      debugPrint('Error fetching location: $error. Using default location.');
      return defLocation;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      debugPrint('Requesting location permission...');
      final permission = await Geolocator.requestPermission();
      final granted = permission == LocationPermission.always ||
                      permission == LocationPermission.whileInUse;
      debugPrint('Permission granted: $granted');
      return granted;
    } catch (error) {
      debugPrint('Error requesting permission: $error');
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      debugPrint('Checking location permission...');
      final permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
                      permission == LocationPermission.whileInUse;
      debugPrint('Permission status: $granted');
      return granted;
    } catch (error) {
      debugPrint('Error checking permission: $error');
      return false;
    }
  }
}
