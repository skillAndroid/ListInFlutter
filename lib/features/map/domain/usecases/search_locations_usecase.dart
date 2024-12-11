import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';

class SearchLocationsUseCase implements UseCase<List<LocationEntity>, String> {
  final LocationRepository repository;

  const SearchLocationsUseCase(this.repository);

  @override
  Future<List<LocationEntity>> call({String? params}) async {
    final result = await repository.searchLocations(params!);

    return result.fold(
        (failure) => throw ServerFailure(), (locations) => locations);
  }
}
