import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/map/domain/entities/address_data_entity.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<LocationEntity>>> searchLocations(String query);
  Future<Either<Failure, AddressDetailsEntity>> getLocation(CoordinatesEntity coordinates);
}
