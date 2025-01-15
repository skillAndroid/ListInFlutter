
class ServerExeption implements Exception {
  final String message;
  ServerExeption({required this.message});

  @override
  String toString() {
    return "Server exeption: $message";
  }
}

class BadResponse implements Exception {
  final String message;
  BadResponse({required this.message});

  @override
  String toString() {
    return "Bad response exeption: $message";
  }
}

class BadRequestExeption implements Exception {
  final String message;
  BadRequestExeption({required this.message});

  @override
  String toString() {
    return "Bad request exeption: $message";
  }
}

class ConnectionExeption implements Exception {
  final String message;
  ConnectionExeption({required this.message});

  @override
  String toString() {
    return "Connection time out exeption: $message";
  }
}


class ConnectiontTimeOutExeption implements Exception {
  ConnectiontTimeOutExeption();
}


class UknownExeption implements Exception {
  UknownExeption();
}


class NotFoundExeption implements Exception {
  NotFoundExeption();
}


class AuthExeption implements Exception {
  AuthExeption();
}


class CacheExeption implements Exception {
  final String message;
  CacheExeption({required this.message});

  @override
  String toString() {
    return "Cache exeption: $message";
  }
}


class UnImplementedExeption implements Exception {
  final String message;
  UnImplementedExeption({required this.message});

  @override
  String toString() {
    return "Server exeption: $message";
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}
