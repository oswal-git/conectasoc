// lib/features/users/presentation/bloc/profile/profile_state.dart
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
  final String? newImagePath; // Ruta local de la nueva imagen seleccionada

  const ProfileLoaded(
      {required this.user, this.isSaving = false, this.newImagePath});

  ProfileLoaded copyWith({
    ProfileEntity? user,
    bool? isSaving,
    String? newImagePath,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isSaving: isSaving ?? this.isSaving,
      newImagePath: newImagePath ?? this.newImagePath,
    );
  }

  @override
  List<Object?> get props => [user, isSaving, newImagePath];
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

// Estado para indicar que el perfil se ha guardado correctamente.
class ProfileUpdateSuccess extends ProfileState {}
