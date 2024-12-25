abstract class Failure {
  List<dynamic> properties = const <dynamic>[];
}

class ServerFailure extends Failure {}

class NetworkFailure extends Failure {}

class CacheFailure extends Failure {}

class ValidationFailure extends Failure{}

class UnexpectedFailure extends Failure{}
