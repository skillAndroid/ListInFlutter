///[ServerExeption] To handle server Exeption
class ServerExeption implements Exception {
  final String message;
  ServerExeption({required this.message});

  @override
  String toString() {
    return "Server exeption: $message";
  }
}

///[BadResponse] To handle bad request exeption
class BadResponse implements Exception {
  final String message;
  BadResponse({required this.message});

  @override
  String toString() {
    return "Bad response exeption: $message";
  }
}

///[BadRequestExeption] To handle bad request exeption
class BadRequestExeption implements Exception {
  final String message;
  BadRequestExeption({required this.message});

  @override
  String toString() {
    return "Bad request exeption: $message";
  }
}

///[ConnectionExeption] To handle connection error Exeption
class ConnectionExeption implements Exception {
  final String message;
  ConnectionExeption({required this.message});

  @override
  String toString() {
    return "Connection time out exeption: $message";
  }
}

///[ConnectiontTimeOutExeption] To handle connection time out Exeption
class ConnectiontTimeOutExeption implements Exception {
  ConnectiontTimeOutExeption();
}

///[UknownExeption] To handle bad request exeption
class UknownExeption implements Exception {
  UknownExeption();
}

///[NotFoundExeption] To handle bad request exeption
class NotFoundExeption implements Exception {
  NotFoundExeption();
}

///[AuthExeption] To handle Auth exeption
class AuthExeption implements Exception {
  AuthExeption();
}

///
class CacheExeption implements Exception {
  final String message;
  CacheExeption({required this.message});

  @override
  String toString() {
    return "Cache exeption: $message";
  }
}

///[UnImplementedExeption] To handle server Exeption
class UnImplementedExeption implements Exception {
  final String message;
  UnImplementedExeption({required this.message});

  @override
  String toString() {
    return "Server exeption: $message";
  }
}
