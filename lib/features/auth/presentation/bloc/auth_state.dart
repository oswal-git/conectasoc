import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carga
class AuthLoading extends AuthState {}

// Usuario Tipo 1 - Local (solo lectura)
class AuthLocalUser extends AuthState {
  final LocalUserEntity localUser;

  const AuthLocalUser(this.localUser);

  @override
  List<Object?> get props => [localUser];
}

// Usuario Tipo 2 - Autenticado en Firebase
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Sin autenticación (ni local ni Firebase)
class AuthUnauthenticated extends AuthState {}

// Error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Estado específico para registro
class AuthRegistrationSuccess extends AuthState {
  final UserEntity user;
  final bool emailVerificationSent;

  const AuthRegistrationSuccess({
    required this.user,
    this.emailVerificationSent = true,
  });

  @override
  List<Object?> get props => [user, emailVerificationSent];
}

// Estado para upgrade de local a registrado
class AuthUpgradeAvailable extends AuthState {
  final LocalUserEntity localUser;

  const AuthUpgradeAvailable(this.localUser);

  @override
  List<Object?> get props => [localUser];
}
