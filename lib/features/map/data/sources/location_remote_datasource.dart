import 'package:dio/dio.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/map/data/models/coordinates_model.dart';
import 'package:list_in/features/map/data/models/location_model.dart';

abstract class LocationRemoteDatasource {
  Future<List<LocationModel>> searchLocations(String query);
  Future<String> getRegionFromCoordinates(CoordinatesModel coordinates);
}

class LocationRemoteDataSourceImpl extends LocationRemoteDatasource {
  final Dio dio;

  LocationRemoteDataSourceImpl({required this.dio});
  @override
  Future<String> getRegionFromCoordinates(CoordinatesModel coordinates) async {
    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': coordinates.latitude,
          'lon': coordinates.longitude,
          'accept-language': 'uz',
        },
        options: Options(
          headers: {'User-Agent': 'ListIn/1.0 (sweetfoxnew@gmail.com)'},
        ),
      );

      if (response.statusCode == 200) {
        final address = response.data['address'];

        // Extract address parts, allowing for null values
        final county = address['county'];
        final city = address['city'];
        final state = address['state'];
        final country = address['country'];

        final addressParts = [
          if (county != null) 'county: $county',
          if (city != null) 'city: $city',
          if (state != null) 'state: $state',
          if (country != null) 'country: $country',
        ].join(', ');

        return addressParts;
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw NetworkFailure();
    }
  }

  @override
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      const apiKey = 'AIzaSyBKW_1Q71Cc0rmsY76nRIwgadSxdq62MtU';
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/textsearch/json',
        queryParameters: {
          'query': query,
          'region': 'UZ',
          'language': 'uz',
          'key': apiKey,
        },
      );
      //h

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((result) {
          final location = result['geometry']['location'];
          return LocationModel(
            name: result['name'] ?? '',
            coordinates: CoordinatesModel(
              latitude: location['lat'] ?? 0.0,
              longitude: location['lng'] ?? 0.0,
            ),
          );
        }).toList();
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw NetworkFailure();
    }
  }
}
