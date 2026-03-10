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

class UserNotificationTime1Changed extends UserEditEvent {
  final String? time;
  const UserNotificationTime1Changed(this.time);

  @override
  List<Object> get props => [time ?? ''];
}

class UserNotificationTime2Changed extends UserEditEvent {
  final String? time;
  const UserNotificationTime2Changed(this.time);

  @override
  List<Object> get props => [time ?? ''];
}

class UserNotificationTime3Changed extends UserEditEvent {
  final String? time;
  const UserNotificationTime3Changed(this.time);

  @override
  List<Object> get props => [time ?? ''];
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
