import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';

class GetPredictionParams {
  final String? query;

  GetPredictionParams({
    this.query,
  });
}

class GetPredictionsUseCase
    extends UseCase2<List<PredictionEntity>, GetPredictionParams> {
  final PublicationsRepository repository;

  GetPredictionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PredictionEntity>>> call(
      {GetPredictionParams? params}) {
    return repository.getPredictions(
      params?.query,
    );
  }
}
