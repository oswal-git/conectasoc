// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class ConcurrencyException implements Exception {
  final String message;
  ConcurrencyException(
      [this.message = 'El registro ha sido modificado por otro usuario.']);

  @override
  String toString() => message;
}
