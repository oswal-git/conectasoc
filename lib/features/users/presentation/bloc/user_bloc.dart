// lib/features/users/presentation/bloc/user_bloc.dart

import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';
import 'package:conectasoc/features/users/presentation/bloc/user_event.dart';
import 'package:conectasoc/features/users/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final JoinAssociationUseCase joinAssociationUseCase;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;
  final AuthBloc authBloc;

  UserBloc({
    required this.joinAssociationUseCase,
    required this.getAllAssociationsUseCase,
    required this.authBloc,
  }) : super(UserInitial()) {
    on<JoinAssociationRequested>(_onJoinAssociationRequested);
    on<LoadAvailableAssociations>(_onLoadAvailableAssociations);
  }

  Future<void> _onJoinAssociationRequested(
    JoinAssociationRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await joinAssociationUseCase(
      userId: event.userId,
      associationId: event.associationId,
    );

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        // Si tiene éxito, refrescamos el estado de autenticación para
        // que toda la app se entere del cambio de membresías.
        authBloc.add(AuthCheckRequested());
        emit(UserUpdateSuccess());
      },
    );
  }

  Future<void> _onLoadAvailableAssociations(
      LoadAvailableAssociations event, Emitter<UserState> emit) async {
    emit(AvailableAssociationsLoading());
    // Fix: Manejar estado de carga del AuthBloc para evitar race conditions
    var authState = authBloc.state;
    if (authState is AuthLoading) {
      authState = await authBloc.stream.firstWhere((s) => s is! AuthLoading);
    }

    if (authState is! AuthAuthenticated) {
      emit(const UserError("Usuario no autenticado"));
      return;
    }
    final userMemberships = authState.user.memberships.keys.toSet();
    final result = await getAllAssociationsUseCase();
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (allAssociations) {
        final available = allAssociations
            .where((assoc) => !userMemberships.contains(assoc.id))
            .toList();
        emit(AvailableAssociationsLoaded(available));
      },
    );
  }
}
