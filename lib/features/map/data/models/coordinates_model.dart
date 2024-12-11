import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';

class CoordinatesModel extends CoordinatesEntity {
  const CoordinatesModel({
    required super.latitude,
    required super.longitude,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
    };
  }
}