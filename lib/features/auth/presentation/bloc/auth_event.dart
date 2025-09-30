import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Verificar estado inicial
class AuthCheckRequested extends AuthEvent {}

// ============================================
// USUARIO LOCAL (Tipo 1)
// ============================================

class AuthSaveLocalUser extends AuthEvent {
  final String displayName;
  final String associationId;

  const AuthSaveLocalUser({
    required this.displayName,
    required this.associationId,
  });

  @override
  List<Object?> get props => [displayName, associationId];
}

// ============================================
// REGISTRO (Tipo 2)
// ============================================

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? associationId;
  final bool createAssociation;
  final String? newAssociationName;
  final String? newAssociationLongName;
  final String? newAssociationEmail;
  final String? newAssociationContactName;
  final String? newAssociationPhone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.associationId,
    this.createAssociation = false,
    this.newAssociationName,
    this.newAssociationLongName,
    this.newAssociationEmail,
    this.newAssociationContactName,
    this.newAssociationPhone,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        firstName,
        lastName,
        phone,
        associationId,
        createAssociation,
        newAssociationName,
        newAssociationLongName,
        newAssociationEmail,
        newAssociationContactName,
        newAssociationPhone,
      ];
}

// ============================================
// UPGRADE DE LOCAL A REGISTRADO
// ============================================

class AuthUpgradeToRegistered extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  const AuthUpgradeToRegistered({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone];
}

// ============================================
// LOGIN
// ============================================

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final String? associationId;

  const AuthSignInRequested({
    required this.email,
    required this.password,
    this.associationId,
  });

  @override
  List<Object?> get props => [email, password, associationId];
}

// ============================================
// RECUPERACIÓN DE CONTRASEÑA
// ============================================

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

// ============================================
// LOGOUT
// ============================================

class AuthSignOutRequested extends AuthEvent {}

// Eliminar usuario local
class AuthDeleteLocalUser extends AuthEvent {}
