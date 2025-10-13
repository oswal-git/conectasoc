import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStateChanged extends AuthEvent {
  final firebase.User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object> get props => [user ?? ''];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthSwitchMembership extends AuthEvent {
  final MembershipEntity newMembership;

  const AuthSwitchMembership(this.newMembership);

  @override
  List<Object> get props => [newMembership];
}

class AuthLeaveAssociation extends AuthEvent {
  final MembershipEntity membership;

  const AuthLeaveAssociation(this.membership);

  @override
  List<Object> get props => [membership];
}

class AuthLoadRegisterData extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSaveLocalUser extends AuthEvent {
  final String displayName;
  final String associationId;

  const AuthSaveLocalUser(
      {required this.displayName, required this.associationId});

  @override
  List<Object> get props => [displayName, associationId];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool createAssociation;
  final String? associationId;
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
    required this.createAssociation,
    this.associationId,
    this.newAssociationName,
    this.newAssociationLongName,
    this.newAssociationEmail,
    this.newAssociationContactName,
    this.newAssociationPhone,
  });

  @override
  List<Object> get props => [email, password, firstName, lastName, phone ?? ''];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthDeleteLocalUser extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

class AuthUserUpdated extends AuthEvent {
  final UserEntity user;

  const AuthUserUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// Evento interno para manejar los cambios del stream de autenticación de Firebase.
class AuthUserChanged extends AuthEvent {
  final firebase.User? firebaseUser;

  const AuthUserChanged(this.firebaseUser);
}

/// Requests to refresh the current user's data from the repository without triggering global navigation.
class AuthUserRefreshRequested extends AuthEvent {}
