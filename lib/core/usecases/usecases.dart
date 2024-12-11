import 'package:list_in/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Type> call({Params? params}) {
    // Default implementation that throws a generic Failure
    throw ServerFailure();
  }
}

class NoParams {}
