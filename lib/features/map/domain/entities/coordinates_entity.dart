import 'package:list_in/features/map/data/models/coordinates_model.dart';
 class CoordinatesEntity {
  final double latitude;
  final double longitude;

  const CoordinatesEntity({
    required this.latitude,
    required this.longitude,
  });

  CoordinatesModel toModel() =>
      CoordinatesModel(latitude: latitude, longitude: longitude);
}
