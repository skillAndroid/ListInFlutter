import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/map/domain/entities/address_data_entity.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';

class GetLocationUseCase
    implements UseCase<AddressDetailsEntity, CoordinatesEntity> {
  LocationRepository repository;

  GetLocationUseCase(this.repository);

  @override
  Future<AddressDetailsEntity> call({CoordinatesEntity? params}) async {
    final result = await repository.getLocation(params!);
    return result.fold(
        (failure) => throw ServerFailure(), (addressDetails) => addressDetails);
  }
}
