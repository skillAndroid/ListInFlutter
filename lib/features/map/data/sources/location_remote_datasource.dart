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
        'https://geocode-maps.yandex.ru/1.x/',
        queryParameters: {
          'format': 'json',
          'geocode': '${coordinates.longitude},${coordinates.latitude}',
          'apikey': "4230cbbd-2351-4199-abf8-08d61e81f0cd",
          'lang': 'en', // Optional: Set the language for the response
        },
      );

      if (response.statusCode == 200) {
        final featureMembers =
            response.data['response']['GeoObjectCollection']['featureMember'];
        if (featureMembers != null && featureMembers.isNotEmpty) {
          final geoObject = featureMembers[0]['GeoObject'];
          final addressDetails = geoObject['metaDataProperty']
              ['GeocoderMetaData']['Address']['Components'];

          String? county;
          String? city;
          String? state;
          String? country;

          for (var component in addressDetails) {
            final kind = component['kind'];
            final name = component['name'];

            switch (kind) {
              case 'province':
                state = name;
                break;
              case 'area':
                county = name;
                break;
              case 'country':
                country = name;
                break;
            }
          }

          final addressParts = [
            if (county != null) 'county: $county',
            if (city != null) 'city: $city',
            if (state != null) 'state: $state',
            if (country != null) 'country: $country',
          ].join(', ');

          return addressParts;
        } else {
          throw ServerFailure(); // No results found
        }
      } else {
        throw ServerFailure(); // Non-200 status code
      }
    } catch (e) {
      throw NetworkFailure(); // Network or other errors
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
          'language': 'en',
          'key': apiKey,
        },
      );

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
