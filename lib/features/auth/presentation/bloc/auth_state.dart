// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
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
  final MembershipEntity? currentMembership;

  const AuthAuthenticated(this.user, this.currentMembership);

  @override
  @override
  List<Object?> get props => [user, currentMembership];
}

// Sin autenticación (ni local ni Firebase)
class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

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

  const AuthRegistrationSuccess(
      {required this.user, this.emailVerificationSent = true});

  @override
  List<Object?> get props => [user, emailVerificationSent];
}

// Estado para cargar datos en la página de registro
class AuthRegisterDataLoaded extends AuthState {
  final bool isFirstUser;
  final List<AssociationEntity> associations;

  const AuthRegisterDataLoaded(
      {required this.isFirstUser, required this.associations});

  @override
  List<Object?> get props => [isFirstUser, associations];
}

// Estado para upgrade de local a registrado
class AuthUpgradeAvailable extends AuthState {
  final LocalUserEntity localUser;

  const AuthUpgradeAvailable(this.localUser);

  @override
  List<Object?> get props => [localUser];
}

class AuthNeedsVerification extends AuthState {
  final String email;
  const AuthNeedsVerification(this.email);

  @override
  List<Object> get props => [email];
}

class RegisterInitial extends AuthState {}

class RegisterLoading extends AuthState {}

class RegisterDataLoaded extends AuthState {
  final List<AssociationEntity> associations;
  final bool isFirstUser;

  const RegisterDataLoaded(
      {required this.associations, required this.isFirstUser});

  @override
  List<Object> get props => [associations, isFirstUser];
}
