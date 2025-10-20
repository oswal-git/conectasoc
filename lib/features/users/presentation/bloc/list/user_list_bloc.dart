import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/usecases/get_all_users_usecase.dart';
import 'package:conectasoc/features/users/domain/usecases/get_users_by_association_usecase.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetUsersByAssociationUseCase getUsersByAssociationUseCase;

  UserListBloc({
    required this.getAllUsersUseCase,
    required this.getUsersByAssociationUseCase,
  }) : super(UserListInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers,
        transformer: debounce(const Duration(milliseconds: 300)));
    on<SortUsers>(_onSortUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserListState> emit,
  ) async {
    emit(UserListLoading());

    // Si se proporciona un associationId, cargamos solo los usuarios de esa asociación (para admins).
    // Si no, cargamos todos los usuarios (para superadmins).
    final result = event.associationId != null
        ? await getUsersByAssociationUseCase(event.associationId!)
        : await getAllUsersUseCase();

    result.fold(
      (failure) => emit(UserListError(failure.message)),
      (users) {
        // Ordenamos los usuarios alfabéticamente por nombre completo por defecto.
        users.sort((a, b) => a.fullName.compareTo(b.fullName));
        emit(UserListLoaded(allUsers: users, filteredUsers: users));
      },
    );
  }

  void _onSearchUsers(
    SearchUsers event,
    Emitter<UserListState> emit,
  ) {
    if (state is UserListLoaded) {
      final currentState = state as UserListLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.allUsers.where((user) {
        return user.fullName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
      emit(currentState.copyWith(filteredUsers: filtered));
    }
  }

  void _onSortUsers(SortUsers event, Emitter<UserListState> emit) {
    final currentState = state;
    if (currentState is! UserListLoaded) return;

    final sortedUsers = List<UserEntity>.from(currentState.filteredUsers);

    switch (event.sortOption) {
      case UserSortOption.name:
        sortedUsers.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case UserSortOption.email:
        sortedUsers.sort((a, b) => a.email.compareTo(b.email));
        break;
    }

    emit(
      currentState.copyWith(
          filteredUsers: sortedUsers, sortOption: event.sortOption),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
