// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/data/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/repositories/repositories.dart';
import 'package:conectasoc/features/auth/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/services/notification_service.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:logger/logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final RegisterUseCase registerUseCase;
  final SaveLocalUserUseCase saveLocalUserUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;

  StreamSubscription<firebase.User?>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Flag para evitar race conditions durante logout
  bool _isLoggingOut = false;

  // Flag para ignorar authStateChanges durante el registro
  bool _isRegistering = false;

  final logger = Logger();

  AuthBloc({
    required this.repository,
    required this.registerUseCase,
    required this.saveLocalUserUseCase,
    required this.getAllAssociationsUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoadRegisterData>(_onLoadRegisterData);
    on<AuthSwitchMembership>(_onSwitchMembership);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLeaveAssociation>(_onLeaveAssociation);
    on<AuthSaveLocalUser>(_onSaveLocalUser);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUserUpdated>(_onUserUpdated);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteLocalUser>(_onDeleteLocalUser);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthRegistrationCompleted>(_onRegistrationCompleted);
    on<AuthUserRefreshRequested>(_onUserRefreshRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  @override
  Future<void> close() {
    logger.t("⏸️ AuthBloc-close: cancel subscriptions");
    _userSubscription?.cancel();
    _userDocSubscription?.cancel();
    return super.close();
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final currentAssociationId =
          currentState.currentMembership?.associationId;
      final updatedMembership = (currentAssociationId != null &&
              event.user.memberships.containsKey(currentAssociationId))
          ? currentState.currentMembership
          : event.user.memberships.entries.firstOrNull
              ?.toMembershipEntity(userId: event.user.uid);

      logger.t("➡️ AuthBloc-_onUserUpdated: emit(AuthAuthenticated)");
      emit(AuthAuthenticated(event.user, updatedMembership));
      // Programar notificaciones
      sl<NotificationService>().scheduleNotifications(event.user);
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    logger.t(
        '📥 AuthBloc-_onAuthUserChanged: - isRegistering: $_isRegistering, isLoggingOut: $_isLoggingOut');

    // CRÍTICO: Ignorar eventos durante logout Y durante registro
    if (_isLoggingOut || _isRegistering) {
      logger.t(
          '⏭️ IGNORANDO AuthBloc-_onAuthUserChanged: (registering: $_isRegistering, logging out: $_isLoggingOut)');
      return;
    }

    logger.t(
        '✅ AuthBloc-_onAuthUserChanged: Procesando AuthUserChanged normalmente');

    final firebaseUser = event.firebaseUser;
    if (firebaseUser == null) {
      logger.t("⏸️ AuthBloc-_onAuthUserChanged: _cancelUserDocSubscription");
      await _cancelUserDocSubscription();
      logger.t("➡️ AuthBloc-_onAuthUserChanged: emit(AuthUnauthenticated)");
      emit(AuthUnauthenticated());
    } else {
      logger.t("⏸️ AuthBloc-_onAuthUserChanged: _cancelUserDocSubscription");
      await _cancelUserDocSubscription();

      // CRÍTICO: Verificar email ANTES de intentar leer de Firestore
      if (!firebaseUser.emailVerified) {
        logger.t("➡️ AuthBloc-_onAuthUserChanged: emit(AuthNeedsVerification)");
        emit(AuthNeedsVerification(firebaseUser.email!));
        return;
      }

      // Solo intentar leer de Firestore si el email está verificado
      final userResult = await repository.getCurrentUser();
      userResult.fold(
        (failure) {
          logger.t(
              "➡️ AuthBloc-_onAuthUserChanged: emit(AuthError): ${failure.message}");
          emit(AuthError(failure.message));
        },
        (user) {
          if (user != null) {
            final realMemberships = user.memberships.entries
                .where((entry) => entry.key != 'superadmin_access');

            final currentMembership = realMemberships.firstOrNull
                ?.toMembershipEntity(userId: user.uid);
            logger.t("➡️ AuthBloc-_onAuthUserChanged: emit(AuthAuthenticated)");
            emit(AuthAuthenticated(user, currentMembership));
            // Programar notificaciones
            sl<NotificationService>().scheduleNotifications(user);

            if (!_isLoggingOut) {
              logger.t("AuthBloc-_onAuthUserChanged: _startUserDocListener");
              _startUserDocListener(user);
            }
          } else {
            logger.t(
                "▶️ AuthBloc-_onAuthUserChanged: event(AuthSignOutRequested)");
            add(AuthSignOutRequested());
          }
        },
      );
    }
  }

  void _startUserDocListener(UserEntity user) {
    logger.t("AuthBloc-_startUserDocListener: _userDocSubscription");
    _userDocSubscription =
        _firestore.collection('users').doc(user.uid).snapshots().listen(
      (snapshot) {
        if (_isLoggingOut) return;

        if (snapshot.exists && state is AuthAuthenticated) {
          final serverUser = UserModel.fromFirestore(snapshot,
              isEmailVerified: user.isEmailVerified);
          if (serverUser.configVersion >
              (state as AuthAuthenticated).user.configVersion) {
            logger.t(
                "▶️ AuthBloc-_startUserDocListener: event(AuthSignOutRequested)");
            add(AuthSignOutRequested(
                message:
                    'Tus permisos han cambiado. Por favor, inicia sesión de nuevo.'));
          }
        }
      },
      onError: (error) {
        if (!_isLoggingOut) {
          logger.t(
              '💥 AuthBloc-_startUserDocListener -> Error en listener de usuario: $error');
        }
      },
      cancelOnError: false,
    );
  }

  Future<void> _cancelUserDocSubscription() async {
    logger.t(
        "⏸️ AuthBloc-_cancelUserDocSubscription: cancel _userDocSubscription");
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;
  }

  void _onSwitchMembership(
    AuthSwitchMembership event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      if (currentState.user.isSuperAdmin && event.newMembership == null) {
        logger.t(
            "➡️ AuthBloc-_onSwitchMembership: emit(AuthAuthenticated(isSuperAdmin))");
        emit(AuthAuthenticated(currentState.user, null));
      } else {
        logger.t("➡️ AuthBloc-_onSwitchMembership: emit(AuthAuthenticated)");
        emit(AuthAuthenticated(currentState.user, event.newMembership));
      }
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.t("➡️ AuthBloc-_onAuthCheckRequested: emit(AuthLoading)");
    emit(AuthLoading());

    // CRÍTICO: Iniciar el listener SOLO cuando se hace el check inicial
    if (_userSubscription == null) {
      logger.t(
          '🎯 AuthBloc-_onAuthCheckRequested: Iniciando authStateChanges _userSubscription listener');
      _userSubscription = repository.authStateChanges.listen((user) {
        logger.t("▶️ AuthBloc-_onAuthCheckRequested: event(AuthUserChanged)");
        add(AuthUserChanged(user));
      });
    }

    final currentUserResult = await repository.getCurrentUser();
    final user = currentUserResult.getOrElse(() => null);

    if (user != null && !user.isLocalUser && !user.isEmailVerified) {
      logger
          .t("➡️ AuthBloc-_onAuthCheckRequested: emit(AuthNeedsVerification)");
      emit(AuthNeedsVerification(user.email));
      return;
    }

    if (user != null) {
      final realMemberships = user.memberships.entries
          .where((entry) => entry.key != 'superadmin_access');

      final currentMembership =
          realMemberships.firstOrNull?.toMembershipEntity(userId: user.uid);
      logger.t("➡️ AuthBloc-_onAuthCheckRequested: emit(AuthAuthenticated)");
      emit(AuthAuthenticated(user, currentMembership));
      // Programar notificaciones
      sl<NotificationService>().scheduleNotifications(user);

      // Iniciar listener del documento del usuario
      if (!_isLoggingOut && !_isRegistering) {
        logger.t("↗️ AuthBloc-_onAuthCheckRequested: _startUserDocListener");
        _startUserDocListener(user);
      }
      return;
    }

    final hasLocalResult = await repository.hasLocalUser();
    final hasLocal = hasLocalResult.getOrElse(() => false);

    if (hasLocal) {
      final localUserResult = await repository.getLocalUser();
      localUserResult.fold(
        (failure) {
          logger.t(
              "➡️ AuthBloc-_onAuthCheckRequested: emit(AuthUnauthenticated)");
          emit(AuthUnauthenticated());
        },
        (LocalUserEntity? localUser) {
          if (localUser != null) {
            logger.t("➡️ AuthBloc-_onAuthCheckRequested: emit(AuthLocalUser)");
            emit(AuthLocalUser(localUser));
          } else {
            logger.t(
                "➡️ AuthBloc-_onAuthCheckRequested: emit(AuthUnauthenticated)");
            emit(AuthUnauthenticated());
          }
        },
      );
    } else {
      logger.t("➡️ AuthBloc-_onAuthCheckRequested: emit(AuthUnauthenticated)");
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
          // Keep old state on failure
        },
        (user) {
          if (user != null) {
            logger.t(
                "▶️ AuthBloc-_onUserRefreshRequested: event(AuthUserUpdated)");
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
    logger.t("➡️ AuthBloc-_onSaveLocalUser: emit(AuthLoading)");
    emit(AuthLoading());
    final result = await saveLocalUserUseCase(
      displayName: event.displayName,
      associationId: event.associationId,
    );

    if (result.isLeft()) {
      final failure = (result as Left).value as Failure;
      logger.t(
          "➡️ AuthBloc-_onSaveLocalUser: emit(AuthError): ${failure.message}");
      emit(AuthError(failure.message));
      return;
    }

    final localUserResult = await repository.getLocalUser();
    emit(localUserResult.fold(
      (failure) {
        logger.t(
            "➡️ AuthBloc-_onSaveLocalUser: emit(AuthError): ${failure.message}");
        return AuthError(failure.message);
      },
      (localUser) {
        if (localUser != null) {
          logger.t("➡️ AuthBloc-_onSaveLocalUser: emit(AuthLocalUser)");
          return AuthLocalUser(localUser);
        } else {
          logger.t(
              "➡️ AuthBloc-_onSaveLocalUser: emit(AuthError): Error obteniendo usuario local");
          return const AuthError('Error obteniendo usuario local');
        }
      },
    ));
  }

  Future<void> _onLoadRegisterData(
    AuthLoadRegisterData event,
    Emitter<AuthState> emit,
  ) async {
    logger.t("➡️ AuthBloc-_onLoadRegisterData: emit(RegisterLoading)");
    emit(RegisterLoading());
    final result = await getAllAssociationsUseCase();
    result.fold(
      (failure) {
        logger.t(
            "➡️ AuthBloc-_onLoadRegisterData: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));
      },
      (associations) {
        logger.t("➡️ AuthBloc-_onLoadRegisterData: emit(RegisterDataLoaded)");
        emit(RegisterDataLoaded(
          associations: associations,
          isFirstUser: false,
        ));
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.t("➡️ AuthBloc-_onSignInRequested: emit(AuthLoading)");
    emit(AuthLoading());

    // Iniciar el listener si no existe
    if (_userSubscription == null) {
      logger.t(
          '🎯 AuthBloc-_onSignInRequested: Iniciando authStateChanges listener');
      _userSubscription = repository.authStateChanges.listen((user) {
        logger.t("▶️ AuthBloc-_onSignInRequested: event(AuthUserChanged)");
        add(AuthUserChanged(user));
      });
    }

    // CRÍTICO: Solo autenticar en Firebase Auth, NO leer de Firestore
    // El listener authStateChanges se encargará del resto
    try {
      await repository.signInWithEmailOnly(
        email: event.email,
        password: event.password,
      );
      logger.t(
          "✅ AuthBloc-_onSignInRequested: Login exitoso, esperando AuthUserChanged");
    } catch (e) {
      logger.t("➡️ AuthBloc-_onSignInRequested: emit(AuthError): $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.t('🔴 INICIANDO REGISTRO');

    // CRÍTICO: Establecer el flag INMEDIATAMENTE, antes de cualquier await
    _isRegistering = true;
    logger.t('🔴 Flag _isRegistering = $_isRegistering');

    // Cancelar TODOS los listeners
    logger.t('🔴 Cancelando userSubscription');
    await _userSubscription?.cancel();
    _userSubscription = null;

    logger.t('🔴 Cancelando userDocSubscription');
    await _cancelUserDocSubscription();

    logger.t("➡️ AuthBloc-_onRegisterRequested: emit(AuthLoading)");
    emit(AuthLoading());

    // Pequeño delay para asegurar que los listeners se cancelaron
    await Future.delayed(const Duration(milliseconds: 100));

    logger.t('🟢 LLAMANDO registerUseCase');
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
    logger.t('🟢 registerUseCase COMPLETADO');

    // Desmarcar flag ANTES de procesar el resultado
    logger.t('🔴 Flag _isRegistering = false');
    _isRegistering = false;

    result.fold(
      (failure) {
        logger.t('🔴 ERROR EN REGISTRO: ${failure.message}');
        logger.t(
            "➡️ AuthBloc-_onRegisterRequested: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));

        // Solo reactivar el listener si hubo error (para reintentar)
        logger.t('🔴 REACTIVANDO authStateChanges subscription (error case)');
        _userSubscription = repository.authStateChanges.listen((user) {
          logger.t("▶️ AuthBloc-_onRegisterRequested: event(AuthUserChanged)");
          add(AuthUserChanged(user));
        });
      },
      (_) {
        logger.t(
            '🟢 REGISTRO EXITOSO, emitiendo AuthNeedsVerification directamente');
        logger
            .t("➡️ AuthBloc-_onRegisterRequested: emit(AuthNeedsVerification)");
        // CRÍTICO: NO reactivar el listener aquí porque este bloc va a cerrarse
        // El AuthBloc global de main.dart se encargará de manejar el estado
        emit(AuthNeedsVerification(event.email));
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _isLoggingOut = true;
    logger.t("➡️ AuthBloc-_onSignOutRequested: emit(AuthLoading)");
    emit(AuthLoading());

    logger.t("⏸️ AuthBloc-_onSignOutRequested: _cancelUserDocSubscription");
    await _cancelUserDocSubscription();

    final result = await repository.signOut();

    result.fold(
      (failure) {
        _isLoggingOut = false;
        logger.t(
            "➡️ AuthBloc-_onSignOutRequested: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));
      },
      (_) {
        logger.t("➡️ AuthBloc-_onSignOutRequested: emit(AuthUnauthenticated)");
        emit(AuthUnauthenticated());
        Future.delayed(const Duration(milliseconds: 100), () {
          _isLoggingOut = false;
        });
      },
    );
  }

  Future<void> _onDeleteLocalUser(
    AuthDeleteLocalUser event,
    Emitter<AuthState> emit,
  ) async {
    final result = await repository.deleteLocalUser();

    result.fold(
      (failure) {
        logger.t(
            "➡️ AuthBloc-_onDeleteLocalUser: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));
      },
      (_) {
        logger.t("➡️ AuthBloc-_onDeleteLocalUser: emit(AuthUnauthenticated)");
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await repository.resetPasswordWithEmail(event.email);

    result.fold(
      (failure) {
        logger.t(
            "➡️ AuthBloc-_onPasswordResetRequested: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));
      },
      (_) {
        // El stream se encargará de emitir AuthUnauthenticated
      },
    );
  }

  Future<void> _onLeaveAssociation(
    AuthLeaveAssociation event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    if (currentState.user.memberships.length <= 1) {
      logger.t(
          "➡️ AuthBloc-_onLeaveAssociation: emit(AuthError): No puedes abandonar tu última asociación.");
      emit(const AuthError('No puedes abandonar tu última asociación.'));
      logger.t("➡️ AuthBloc-_onLeaveAssociation: emit(currentState)");
      emit(currentState);
      return;
    }

    logger.t("➡️ AuthBloc-_onLeaveAssociation: emit(AuthLoading)");
    emit(AuthLoading());

    final result = await repository.leaveAssociation(event.membership);

    result.fold(
      (failure) {
        logger.t(
            "➡️ AuthBloc-_onPasswordResetRequested: emit(AuthError): ${failure.message}");
        emit(AuthError(failure.message));
        logger.t("➡️ AuthBloc-_onLeaveAssociation: emit(currentState)");
        emit(currentState);
      },
      (_) {
        MembershipEntity? newMembership = currentState.currentMembership;
        if (currentState.currentMembership?.associationId ==
            event.membership.associationId) {
          newMembership = null;
        }
        logger.t("➡️ AuthBloc-_onLeaveAssociation: emit(AuthAuthenticated)");
        emit(AuthAuthenticated(currentState.user, newMembership));
      },
    );
  }

  void _onRegistrationCompleted(
    AuthRegistrationCompleted event,
    Emitter<AuthState> emit,
  ) {
    logger
        .t("➡️ AuthBloc-_onRegistrationCompleted: emit(AuthNeedsVerification)");
    emit(AuthNeedsVerification(event.email));
  }
}
