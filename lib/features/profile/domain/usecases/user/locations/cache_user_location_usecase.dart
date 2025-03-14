import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';

import 'package:list_in/features/post/data/models/location_tree/location_model.dart'
    as models;
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';

// Parameters class for the cache user location use case
class CacheUserLocationParams {
  final models.Country? country;
  final models.State? state;
  final models.County? county;
  final double? longitude;
  final double? latitude;
  final bool? isGrantedForPreciseLocation;
  final String? locationName;

  CacheUserLocationParams({
    this.country,
    this.state,
    this.county,
    this.longitude,
    this.latitude,
    this.isGrantedForPreciseLocation,
    this.locationName,
  });
}

// Use case for getting user location
class GetUserLocationUseCase extends UseCase2<Map<String, dynamic>?, NoParams> {
  final UserProfileRepository repository;

  GetUserLocationUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      {NoParams? params}) async {
    return await repository.getUserLocation();
  }
}
