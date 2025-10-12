// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final RegisterUseCase registerUseCase;
  final SaveLocalUserUseCase saveLocalUserUseCase;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;

  StreamSubscription<firebase.User?>? _userSubscription;

  AuthBloc({
    required this.repository,
    required this.registerUseCase,
    required this.saveLocalUserUseCase,
    required this.getAllAssociationsUseCase,
  }) : super(AuthInitial()) {
    _userSubscription = repository.authStateChanges.listen(_onUserChanged);
    on<AuthLoadRegisterData>(_onLoadRegisterData);
    on<AuthSwitchMembership>(_onSwitchMembership);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLeaveAssociation>(_onLeaveAssociation);
    on<AuthSaveLocalUser>(_onSaveLocalUser);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUserUpdated>(_onUserUpdated);
    // on<AuthUpgradeToRegistered>(_onUpgradeToRegistered); // This event seems to have no implementation yet
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteLocalUser>(_onDeleteLocalUser);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // Al actualizar el usuario, es posible que sus membresías hayan cambiado.
      // Verificamos si la membresía actual sigue existiendo.
      final currentAssociationId =
          currentState.currentMembership?.associationId;
      final updatedMembership = (currentAssociationId != null &&
              event.user.memberships.containsKey(currentAssociationId))
          ? MembershipEntity(
              userId: event.user.uid,
              associationId: currentAssociationId,
              role: event.user.memberships[currentAssociationId]!)
          : event.user.memberships.entries.firstOrNull?.toMembershipEntity(
              userId:
                  event.user.uid); // La extensión también requiere el userId

      emit(AuthAuthenticated(event.user, updatedMembership));
    } else if (currentState is AuthLocalUser) {
      // Si es un usuario local, también actualizamos sus datos.
    }
  }

  void _onUserChanged(firebase.User? firebaseUser) {
    if (firebaseUser == null) {
      // Si no hay usuario de Firebase, comprobamos si hay uno local
      add(AuthCheckRequested());
    } else {
      // Si hay usuario de Firebase, obtenemos sus datos completos
      add(AuthCheckRequested());
    }
  }

  void _onSwitchMembership(
    AuthSwitchMembership event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // El evento ahora pasa una MembershipEntity, que es lo que necesita el estado.
      // Emitir un nuevo estado autenticado con la nueva membresía
      emit(AuthAuthenticated(currentState.user, event.newMembership));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // 1. Check for a Firebase authenticated user
    final currentUserResult = await repository.getCurrentUser();

    final user = currentUserResult.getOrElse(() => null);

    if (user != null) {
      // Case 1: User is authenticated in Firebase.
      // Convertimos la primera entrada del mapa a una MembershipEntity
      final currentMembership = user.memberships.entries.firstOrNull == null
          ? null
          : MembershipEntity(
              userId: user.uid,
              associationId: user.memberships.entries.first.key,
              role: user.memberships.entries.first.value);
      emit(AuthAuthenticated(user, currentMembership));
      return;
    }

    // Case 2: No Firebase user, check for a local user.
    final hasLocalResult = await repository.hasLocalUser();
    final hasLocal = hasLocalResult.getOrElse(() => false);

    if (hasLocal) {
      final localUserResult = await repository.getLocalUser();
      final localUser = localUserResult.getOrElse(() => null);
      if (localUser != null) {
        emit(AuthLocalUser(localUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      // Case 3: No Firebase user and no local user.
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSaveLocalUser(
    AuthSaveLocalUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await saveLocalUserUseCase(
      displayName: event.displayName,
      associationId: event.associationId,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) async {
        final localUserResult = await repository.getLocalUser();
        localUserResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (localUser) {
            if (localUser != null) {
              emit(AuthLocalUser(localUser));
            } else {
              emit(const AuthError('Error obteniendo usuario local'));
            }
          },
        );
      },
    );
  }

  Future<void> _onLoadRegisterData(
    AuthLoadRegisterData event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Cargar las asociaciones disponibles para el formulario de registro.
      // La lógica de 'primer usuario' se ha eliminado por seguridad.
      // El rol de 'superadmin' debe ser asignado manualmente desde Firebase.
      final associationsResult = await getAllAssociationsUseCase();
      associationsResult.fold(
        (failure) => emit(AuthError(failure.message)),
        (associations) {
          emit(AuthRegisterDataLoaded(
            isFirstUser: false, // Se mantiene en false siempre.
            associations: associations,
          ));
        },
      );
    } catch (e) {
      emit(AuthError('Error cargando datos de registro: $e'));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // La lógica de login ahora está directamente en el repositorio
    final result = await repository.signInWithEmail(
        email: event.email, password: event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        final currentMembership = user.memberships.entries.firstOrNull == null
            ? null
            : MembershipEntity(
                userId: user.uid,
                associationId: user.memberships.entries.first.key,
                role: user.memberships.entries.first.value);

        emit(AuthAuthenticated(user, currentMembership));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      createAssociation: event.createAssociation,
      associationId: event.associationId,
      newAssociationName: event.newAssociationName,
      newAssociationLongName: event.newAssociationLongName,
      newAssociationEmail: event.newAssociationEmail,
      newAssociationContactName: event.newAssociationContactName,
      newAssociationPhone: event.newAssociationPhone,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Tras un registro exitoso, autenticamos al usuario directamente.
        final currentMembership = user.memberships.entries.firstOrNull == null
            ? null
            : MembershipEntity(
                userId: user.uid,
                associationId: user.memberships.entries.first.key,
                role: user.memberships.entries.first.value);
        emit(AuthAuthenticated(user, currentMembership));
      },
    );
  }

  // Future<void> _onUpgradeToRegistered(
  //   AuthUpgradeToRegistered event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());

  //   final result = await repository.upgradeLocalToRegistered(
  //     email: event.email,
  //     password: event.password,
  //     firstName: event.firstName,
  //     lastName: event.lastName,
  //     phone: event.phone,
  //   );

  //   result.fold(
  //     (failure) => emit(AuthError(failure.message)),
  //     (user) => emit(AuthRegistrationSuccess(
  //       user: user,
  //       emailVerificationSent: true,
  //     )),
  //   );
  // }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // La lógica de logout ahora está directamente en el repositorio
    final result = await repository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        // No emitimos AuthUnauthenticated directamente,
        // el stream de authStateChanges se encargará de ello.
      },
    );
  }

  Future<void> _onDeleteLocalUser(
    AuthDeleteLocalUser event,
    Emitter<AuthState> emit,
  ) async {
    final result = await repository.deleteLocalUser();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await repository.resetPasswordWithEmail(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        // El stream de authStateChanges se encargará de emitir AuthUnauthenticated
        // tras el logout de Firebase.
      },
    );
  }

  Future<void> _onLeaveAssociation(
    AuthLeaveAssociation event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    // Regla de negocio: No se puede abandonar la última asociación.
    if (currentState.user.memberships.length <= 1) {
      emit(const AuthError(
          'No puedes abandonar tu última asociación. Debes eliminar tu cuenta.'));
      // Volver al estado autenticado anterior para que la UI no se quede en error.
      emit(currentState);
      return;
    }

    emit(AuthLoading());

    final result = await repository.leaveAssociation(event.membership);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        add(AuthCheckRequested()); // Recargar el estado del usuario
      },
    );
  }
}
