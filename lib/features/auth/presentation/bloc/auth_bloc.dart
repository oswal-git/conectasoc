// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SaveLocalUserUseCase saveLocalUserUseCase;
  final GetAssociationsUseCase getAssociationsUseCase;

  StreamSubscription<firebase.User?>? _userSubscription;

  AuthBloc({
    required this.repository,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.saveLocalUserUseCase,
    required this.getAssociationsUseCase,
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
      // Emitir un nuevo estado con el usuario actualizado, manteniendo la membresía actual.
      emit(AuthAuthenticated(event.user, currentState.currentMembership));
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
      // Emitir un nuevo estado autenticado con la nueva membresía
      emit(AuthAuthenticated(currentState.user, event.newMembership));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // 1. Verificar usuario Firebase
    final currentUserResult = await repository.getCurrentUser();

    await currentUserResult.fold(
      (failure) async {
        // Si falla obtener usuario remoto, verificar local
        final hasLocalResult = await repository.hasLocalUser();

        hasLocalResult.fold(
          (failure) => emit(AuthUnauthenticated()),
          (hasLocal) async {
            if (hasLocal) {
              final localUserResult = await repository.getLocalUser();
              localUserResult.fold(
                (failure) => emit(AuthUnauthenticated()),
                (localUser) {
                  if (localUser != null) {
                    emit(AuthLocalUser(localUser));
                  } else {
                    emit(AuthUnauthenticated());
                  }
                },
              );
            } else {
              emit(AuthUnauthenticated());
            }
          },
        );
      },
      (user) async {
        if (user != null) {
          // Si el usuario está autenticado, seleccionamos la primera membresía como la actual por defecto.
          // En el futuro, se podría guardar la última seleccionada o preguntar al usuario.
          final currentMembership =
              user.memberships.isNotEmpty ? user.memberships.first : null;
          emit(AuthAuthenticated(user, currentMembership));
        } else {
          // No hay usuario Firebase, verificar local
          final hasLocalResult = await repository.hasLocalUser();

          hasLocalResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (hasLocal) async {
              if (hasLocal) {
                final localUserResult = await repository.getLocalUser();
                localUserResult.fold(
                  (failure) => emit(AuthUnauthenticated()),
                  (localUser) {
                    if (localUser != null) {
                      emit(AuthLocalUser(localUser));
                    } else {
                      emit(AuthUnauthenticated());
                    }
                  },
                );
              } else {
                emit(AuthUnauthenticated());
              }
            },
          );
        }
      },
    );
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
      final associationsResult = await getAssociationsUseCase();
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

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        final currentMembership =
            user.memberships.isNotEmpty ? user.memberships.first : null;
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
        final currentMembership =
            user.memberships.isNotEmpty ? user.memberships.first : null;
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

    final result = await logoutUseCase();

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
