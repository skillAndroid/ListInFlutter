abstract class Failure {
  List<dynamic> properties = const <dynamic>[];
}

class ServerFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Server Error occurred';
}

class NetworkFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Network Error occurred';
}

class CacheFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Cache Error occurred';
}

class ValidationFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Validation Error occurred';
}

class UnexpectedFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Unexpected Error occurred';
}

class InvalidParamsFailure extends Failure {
  @override
  List<Object> get properties => [];

  @override
  String toString() => 'Invalid parameters provided';
}

class CancellationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class RegistrationNeededFailure extends Failure {
  @override
  String toString() => 'Registration needed';
}
