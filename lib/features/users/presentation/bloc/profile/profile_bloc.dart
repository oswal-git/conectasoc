import 'dart:io';

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/repositories/users_repository.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ProfileNameChanged>(_onProfileNameChanged);
    on<ProfileLastnameChanged>(_onProfileLastnameChanged);
    on<ProfilePhoneChanged>(_onProfilePhoneChanged);
    on<ProfileLanguageChanged>(_onProfileLanguageChanged);
    on<ProfileImageChanged>(_onProfileImageChanged);
    on<SaveProfileChanges>(_onSaveProfileChanges);
  }

  void _onLoadUserProfile(LoadUserProfile event, Emitter<ProfileState> emit) {
    final authState = event.authBloc.state;
    if (authState is AuthAuthenticated) {
      // El UserEntity del AuthBloc ya tiene toda la información necesaria.
      // En una app más compleja, aquí podrías llamar a _userRepository.getUserDetails(authState.user.uid)
      // si necesitaras más datos que los que ya están en el estado de autenticación.
      emit(ProfileLoaded(user: authState.user.toProfileEntity()));
    } else {
      // Esto no debería ocurrir si la página de perfil está protegida.
      emit(const ProfileUpdateFailure('Usuario no autenticado.'));
    }
  }

  void _onProfileNameChanged(
      ProfileNameChanged event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedUser = currentState.user.copyWith(name: event.name);
      emit(currentState.copyWith(user: updatedUser));
    }
  }

  void _onProfileLastnameChanged(
      ProfileLastnameChanged event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedUser = currentState.user.copyWith(lastname: event.lastname);
      emit(currentState.copyWith(user: updatedUser));
    }
  }

  void _onProfilePhoneChanged(
      ProfilePhoneChanged event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedUser = currentState.user.copyWith(phone: event.phone);
      emit(currentState.copyWith(user: updatedUser));
    }
  }

  void _onProfileLanguageChanged(
      ProfileLanguageChanged event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedUser = currentState.user.copyWith(language: event.language);
      emit(currentState.copyWith(user: updatedUser));
    }
  }

  void _onProfileImageChanged(
      ProfileImageChanged event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      // No actualizamos la URL aquí, solo guardamos la ruta local para la subida.
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(newImagePath: event.imagePath));
    }
  }

  void _onSaveProfileChanges(
      SaveProfileChanges event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
          isSaving: true, newImagePath: currentState.newImagePath));

      final result = await _userRepository.updateUser(
        user: currentState.user,
        newImageFile: currentState.newImagePath != null
            ? File(currentState.newImagePath!)
            : null,
      );

      result.fold(
        (failure) {
          emit(ProfileUpdateFailure(failure.message));
          // Revertir al estado anterior al fallo
          emit(currentState.copyWith(isSaving: false));
        },
        (updatedUser) {
          final authBloc = event.authBloc;
          // Asegurarnos de que el estado de autenticación es el correcto
          if (authBloc.state is AuthAuthenticated) {
            final originalAuthUser = (authBloc.state as AuthAuthenticated).user;
            // Actualizar el AuthBloc con el nuevo usuario para que toda la app se entere.
            authBloc
                .add(AuthUserUpdated(updatedUser.toAuthUser(originalAuthUser)));
            // Emitir un estado de éxito para que la UI pueda reaccionar (mostrar SnackBar).
            emit(ProfileUpdateSuccess());
            // Volver al estado cargado, asegurando que la UI tenga los datos más recientes,
            // incluyendo la nueva URL de la imagen si se subió una.
            // También limpiamos el newImagePath local ya que la subida ha finalizado.
            emit(ProfileLoaded(
                user: updatedUser, isSaving: false, newImagePath: null));
          }
        },
      );
    }
  }
}
