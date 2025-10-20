// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final RegisterUseCase registerUseCase;
  final SaveLocalUserUseCase saveLocalUserUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<firebase.User?>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  AuthBloc({
    required this.repository,
    required this.registerUseCase,
    required this.saveLocalUserUseCase,
  }) : super(AuthInitial()) {
    _userSubscription = repository.authStateChanges
        .listen((user) => add(AuthUserChanged(user)));
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
    on<AuthUserRefreshRequested>(_onUserRefreshRequested);
    // Nuevo manejador para el evento interno.
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _userDocSubscription?.cancel();
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
          ? currentState.currentMembership
          : event.user.memberships.entries.firstOrNull?.toMembershipEntity(
              userId:
                  event.user.uid); // La extensión también requiere el userId

      emit(AuthAuthenticated(event.user, updatedMembership));
    } else if (currentState is AuthLocalUser) {
      // Si es un usuario local, también actualizamos sus datos.
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = event.firebaseUser;
    if (firebaseUser == null) {
      // El usuario ha cerrado sesión o nunca ha iniciado sesión.
      // Comprobamos si existe un usuario local (modo solo lectura).
      // En lugar de cargar el usuario local aquí, simplemente indicamos que no está autenticado.
      // El AuthCheckRequested inicial se encargará de la lógica del usuario local.
      emit(AuthUnauthenticated());
    } else {
      _userDocSubscription?.cancel(); // Cancelar suscripción anterior si existe
      // Si el email no está verificado, el usuario no puede continuar.
      if (!firebaseUser.emailVerified) {
        emit(AuthNeedsVerification(firebaseUser.email!));
        return;
      }

      // Hay un usuario de Firebase, obtenemos sus datos completos de Firestore.
      final userResult = await repository.getCurrentUser();
      userResult.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) {
          if (user != null) {
            final currentMembership = user.memberships.entries.firstOrNull
                ?.toMembershipEntity(userId: user.uid);
            emit(AuthAuthenticated(user, currentMembership));

            // Iniciar escucha de cambios en el documento del usuario
            _userDocSubscription = _firestore
                .collection('users')
                .doc(user.uid)
                .snapshots()
                .listen((snapshot) {
              if (snapshot.exists && state is AuthAuthenticated) {
                final serverUser = UserModel.fromFirestore(snapshot,
                    isEmailVerified: user.isEmailVerified);
                if (serverUser.configVersion >
                    (state as AuthAuthenticated).user.configVersion) {
                  add(AuthSignOutRequested(
                      message:
                          'Tus permisos han cambiado. Por favor, inicia sesión de nuevo.'));
                }
              }
            });
          } else {
            // Caso raro: usuario en Auth pero sin documento en Firestore.
            // Forzamos el cierre de sesión para evitar un estado inconsistente.
            add(AuthSignOutRequested());
          }
        },
      );
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

    // Comprobación de email verificado también en el chequeo inicial
    if (user != null && !user.isLocalUser && !user.isEmailVerified) {
      emit(AuthNeedsVerification(user.email));
      return;
    }

    if (user != null) {
      // Case 1: User is authenticated in Firebase.
      // Convertimos la primera entrada del mapa a una MembershipEntity
      final currentMembership = user.memberships.entries.firstOrNull
          ?.toMembershipEntity(userId: user.uid);
      emit(AuthAuthenticated(user, currentMembership));
      return;
    }

    // Case 2: No Firebase user, check for a local user.
    final hasLocalResult = await repository.hasLocalUser();
    final hasLocal = hasLocalResult.getOrElse(() => false);

    if (hasLocal) {
      final localUserResult = await repository.getLocalUser();
      localUserResult.fold(
        (failure) => emit(AuthUnauthenticated()),
        (LocalUserEntity? localUser) {
          if (localUser != null) {
            emit(AuthLocalUser(localUser));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    } else {
      // Case 3: No Firebase user and no local user.
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUserRefreshRequested(
    AuthUserRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final userResult = await repository.getCurrentUser();
      userResult.fold(
        (failure) {
          // On failure, we could emit an error or just keep the old state.
          // For now, we keep the old state to avoid disruption.
        },
        (user) {
          if (user != null) {
            add(AuthUserUpdated(user));
          }
        },
      );
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

    if (result.isLeft()) {
      final failure = (result as Left).value as Failure;
      emit(AuthError(failure.message));
      return;
    }

    // After successfully saving, get the local user to update the state.
    final localUserResult = await repository.getLocalUser();
    emit(localUserResult.fold(
      (failure) => AuthError(failure.message),
      (localUser) => localUser != null
          ? AuthLocalUser(localUser)
          : const AuthError('Error obteniendo usuario local'),
    ));
  }

  Future<void> _onLoadRegisterData(
    AuthLoadRegisterData event,
    Emitter<AuthState> emit,
  ) async {
    // Este evento ha sido eliminado ya que la página de registro ahora
    // carga sus propios datos, desacoplando la lógica de UI del AuthBloc.
    // No se emite ningún estado.
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
        final currentMembership = user.memberships.entries.firstOrNull
            ?.toMembershipEntity(userId: user.uid);
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
        // Tras un registro exitoso, autenticamos al usuario directamente
        final currentMembership = user.memberships.entries.firstOrNull
            ?.toMembershipEntity(userId: user.uid);
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
    // Cancelar la escucha del documento del usuario al cerrar sesión.
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;

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
      // Emitimos un estado de error para que el SnackBar lo muestre.
      emit(const AuthError('No puedes abandonar tu última asociación.'));
      // Inmediatamente después, volvemos al estado anterior para que la UI no se rompa.
      emit(currentState);
      return;
    }

    emit(AuthLoading());

    final result = await repository.leaveAssociation(event.membership);

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(currentState); // Restaurar el estado si falla
      },
      (_) {
        add(AuthCheckRequested()); // Recargar el estado del usuario
      },
    );
  }
}
