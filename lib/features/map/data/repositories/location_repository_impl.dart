import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/map/data/sources/location_remote_datasource.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDatasource remoteDataSource;
  LocationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> getLocation(
      CoordinatesEntity coordinates) async {
    try {
      final region = await remoteDataSource
          .getRegionFromCoordinates(coordinates.toModel());

      return Right(region);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> searchLocations(
    String query,
  ) async {
    try {
      final locations = await remoteDataSource.searchLocations(query);
      return Right(locations);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }
}
