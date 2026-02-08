import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class UserEditEvent extends Equatable {
  const UserEditEvent();

  @override
  List<Object> get props => [];
}

class LoadUserDetails extends UserEditEvent {
  final String userId;
  const LoadUserDetails(this.userId);
}

class UserFirstNameChanged extends UserEditEvent {
  final String firstName;
  const UserFirstNameChanged(this.firstName);
}

class UserLastNameChanged extends UserEditEvent {
  final String lastName;
  const UserLastNameChanged(this.lastName);
}

class UserPhoneChanged extends UserEditEvent {
  final String phone;
  const UserPhoneChanged(this.phone);
}

class UserStatusChanged extends UserEditEvent {
  final UserStatus status;
  const UserStatusChanged(this.status);
}

class UserEmailChanged extends UserEditEvent {
  final String email;
  const UserEmailChanged(this.email);
}

class UserLanguageChanged extends UserEditEvent {
  final String language;
  const UserLanguageChanged(this.language);
}

class UserNotificationFrequencyChanged extends UserEditEvent {
  final String frequency;
  const UserNotificationFrequencyChanged(this.frequency);

  @override
  List<Object> get props => [frequency];
}

class UserRoleChanged extends UserEditEvent {
  final String associationId;
  final String role;
  const UserRoleChanged(this.associationId, this.role);
}

class AddMembership extends UserEditEvent {
  final String associationId;
  final String role;
  const AddMembership(this.associationId, this.role);
}

class RemoveMembership extends UserEditEvent {
  final String associationId;
  const RemoveMembership(this.associationId);
}

class DeleteUser extends UserEditEvent {}

class SaveUserChanges extends UserEditEvent {}

class PrepareUserCreation extends UserEditEvent {}

class UserPasswordChanged extends UserEditEvent {
  final String password;

  const UserPasswordChanged(this.password);
  @override
  List<Object> get props => [password];
}
