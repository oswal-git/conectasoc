import 'dart:async';
import 'package:conectasoc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_event.dart';
import 'package:conectasoc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStatusSubscription;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial()) {
    // Registrar manejadores de eventos
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSaveLocalUser>(_onSaveLocalUser);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUpgradeToRegistered>(_onUpgradeToRegistered);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteLocalUser>(_onDeleteLocalUser);

    // Escuchar cambios en el estado de autenticación de Firebase
    _authStatusSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthCheckRequested()),
    );
  }

  // ============================================
  // VERIFICAR ESTADO INICIAL
  // ============================================

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser != null) {
        // Usuario autenticado en Firebase (Tipo 2)
        final userProfile =
            await _authRepository.getUserProfile(firebaseUser.uid);

        if (userProfile != null && userProfile.isActive) {
          emit(AuthAuthenticated(userProfile));
        } else {
          await _authRepository.signOut();
          emit(AuthUnauthenticated());
        }
      } else {
        // No hay usuario de Firebase, verificar si hay usuario local (Tipo 1)
        if (_authRepository.hasLocalUser()) {
          final localUser = _authRepository.getLocalUser();
          if (localUser != null) {
            emit(AuthLocalUser(localUser));
          } else {
            emit(AuthUnauthenticated());
          }
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthError('Error verificando autenticación: $e'));
    }
  }

  // ============================================
  // GUARDAR USUARIO LOCAL (Tipo 1)
  // ============================================

  Future<void> _onSaveLocalUser(
    AuthSaveLocalUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.saveLocalUser(
        displayName: event.displayName,
        associationId: event.associationId,
      );

      final localUser = _authRepository.getLocalUser();
      if (localUser != null) {
        emit(AuthLocalUser(localUser));
      } else {
        emit(const AuthError('Error guardando usuario local'));
      }
    } catch (e) {
      emit(AuthError('Error: $e'));
    }
  }

  // ============================================
  // REGISTRO (Tipo 2)
  // ============================================

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.registerWithEmail(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        associationId: event.associationId,
        createAssociation: event.createAssociation,
        newAssociationName: event.newAssociationName,
        newAssociationLongName: event.newAssociationLongName,
        newAssociationEmail: event.newAssociationEmail,
        newAssociationContactName: event.newAssociationContactName,
        newAssociationPhone: event.newAssociationPhone,
      );

      emit(AuthRegistrationSuccess(
        user: user,
        emailVerificationSent: true,
      ));

      // Después de mostrar el mensaje de éxito, pasar a autenticado
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error en registro: $e'));
      emit(AuthUnauthenticated());
    }
  }

  // ============================================
  // UPGRADE DE LOCAL A REGISTRADO
  // ============================================

  Future<void> _onUpgradeToRegistered(
    AuthUpgradeToRegistered event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.upgradeLocalToRegistered(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      );

      emit(AuthRegistrationSuccess(
        user: user,
        emailVerificationSent: true,
      ));

      // Después de mostrar el mensaje de éxito, pasar a autenticado
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error actualizando cuenta: $e'));

      // Volver a mostrar usuario local si falla
      final localUser = _authRepository.getLocalUser();
      if (localUser != null) {
        emit(AuthLocalUser(localUser));
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  // ============================================
  // LOGIN
  // ============================================

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
        associationId: event.associationId,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error en login: $e'));
      emit(AuthUnauthenticated());
    }
  }

  // ============================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    try {
      await _authRepository.resetPasswordWithEmail(event.email);

      // Mantener el estado actual pero mostrar mensaje de éxito
      // (esto se manejará en la UI)
    } catch (e) {
      emit(AuthError('Error enviando recuperación: $e'));

      // Restaurar estado anterior
      if (currentState is AuthLocalUser) {
        emit(currentState);
      } else if (currentState is AuthAuthenticated) {
        emit(currentState);
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error cerrando sesión: $e'));
    }
  }

  // ============================================
  // ELIMINAR USUARIO LOCAL
  // ============================================

  Future<void> _onDeleteLocalUser(
    AuthDeleteLocalUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.deleteLocalUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error eliminando usuario local: $e'));
    }
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}
