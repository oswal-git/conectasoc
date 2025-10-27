// lib/features/users/presentation/bloc/profile/profile_state.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity user;
  final bool isSaving;
  final Uint8List? localImageBytes;

  const ProfileLoaded(
      {required this.user, this.localImageBytes, this.isSaving = false});

  ProfileLoaded copyWith(
      {ProfileEntity? user,
      bool? isSaving,
      Uint8List? localImageBytes,
      File? localImageFile}) {
    return ProfileLoaded(
      user: user ?? this.user,
      isSaving: isSaving ?? this.isSaving,
      localImageBytes: localImageBytes ?? this.localImageBytes,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isSaving,
        localImageBytes,
      ];
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

// Estado para indicar que el perfil se ha guardado correctamente.
class ProfileUpdateSuccess extends ProfileState {}
