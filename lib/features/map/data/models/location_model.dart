import 'package:list_in/features/map/data/models/coordinates_model.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.name,
    required super.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      coordinates: CoordinatesModel.fromJson(json['geometry']['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'geometry': {'location': (coordinates as CoordinatesModel).toJson()}
    };
  }
}
