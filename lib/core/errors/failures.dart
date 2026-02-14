// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Errores de servidor/Firebase
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Errores de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Errores de red
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(
            'No hay conexión a internet. Por favor, verifica tu conexión y vuelve a intentarlo.');
}

// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Errores de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// Errores de concurrencia (Optimistic Concurrency Control)
class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure(
      [super.message =
          'El registro ha sido modificado por otro usuario. Por favor, refresca los datos e inténtalo de nuevo.']);
}
