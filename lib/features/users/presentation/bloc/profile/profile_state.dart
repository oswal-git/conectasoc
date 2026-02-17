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
  final ProfileEntity? initialUser;
  final bool isSaving;
  final Uint8List? localImageBytes;

  const ProfileLoaded({
    required this.user,
    this.initialUser,
    this.localImageBytes,
    this.isSaving = false,
  });

  bool get hasChanges {
    // Si hay una imagen local nueva, siempre hay cambios
    if (localImageBytes != null) return true;
    // Si no hay usuario inicial (p.ej. carga inicial), no hay cambios todavía
    if (initialUser == null) return false;
    // Comparar usuario actual con el inicial
    return user != initialUser;
  }

  ProfileLoaded copyWith({
    ProfileEntity? user,
    ProfileEntity? initialUser,
    bool? isSaving,
    Uint8List? localImageBytes,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      initialUser: initialUser ?? this.initialUser,
      isSaving: isSaving ?? this.isSaving,
      localImageBytes: localImageBytes ?? this.localImageBytes,
    );
  }

  @override
  List<Object?> get props => [
        user,
        initialUser,
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
