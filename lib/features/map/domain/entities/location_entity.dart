import 'package:list_in/features/map/data/models/location_model.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
 class LocationEntity {
  final String name;
  final CoordinatesEntity coordinates;

  const LocationEntity({
    required this.name,
    required this.coordinates,
  });

  LocationModel toModel() => LocationModel(name: name, coordinates: coordinates);
}
