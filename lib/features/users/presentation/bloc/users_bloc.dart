// lib/features/users/presentation/bloc/user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';
import 'package:conectasoc/features/users/presentation/bloc/users_event.dart';
import 'package:conectasoc/features/users/presentation/bloc/users_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final JoinAssociationUseCase joinAssociationUseCase;
  final AuthBloc authBloc;

  UserBloc({
    required this.joinAssociationUseCase,
    required this.authBloc,
  }) : super(UserInitial()) {
    on<JoinAssociationRequested>(_onJoinAssociationRequested);
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
}
