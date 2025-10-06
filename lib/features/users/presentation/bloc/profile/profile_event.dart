// lib/features/users/presentation/bloc/profile/profile_event.dart

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final AuthBloc authBloc;
  const LoadUserProfile(this.authBloc);
  @override
  List<Object> get props => [authBloc];
}

class ProfileNameChanged extends ProfileEvent {
  const ProfileNameChanged(this.name);
  final String name;

  @override
  List<Object> get props => [name];
}

class ProfileLastnameChanged extends ProfileEvent {
  const ProfileLastnameChanged(this.lastname);
  final String lastname;

  @override
  List<Object> get props => [lastname];
}

class ProfilePhoneChanged extends ProfileEvent {
  const ProfilePhoneChanged(this.phone);
  final String phone;

  @override
  List<Object> get props => [phone];
}

class ProfileLanguageChanged extends ProfileEvent {
  const ProfileLanguageChanged(this.language);
  final String language;

  @override
  List<Object> get props => [language];
}

class ProfileImageChanged extends ProfileEvent {
  const ProfileImageChanged(this.imagePath);
  final String imagePath;

  @override
  List<Object> get props => [imagePath];
}

class SaveProfileChanges extends ProfileEvent {
  final AuthBloc authBloc;
  const SaveProfileChanges(this.authBloc);
  @override
  List<Object> get props => [authBloc];
}
