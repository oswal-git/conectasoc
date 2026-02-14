import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserEditBloc extends Bloc<UserEditEvent, UserEditState> {
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;
  final CreateUserUseCase createUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UserEditBloc(
      {required this.getUserByIdUseCase,
      required this.updateUserUseCase,
      required this.getAllAssociationsUseCase,
      required this.createUserUseCase,
      required this.deleteUserUseCase})
      : super(UserEditInitial()) {
    on<LoadUserDetails>(_onLoadUserDetails);
    on<UserFirstNameChanged>(_onUserFirstNameChanged);
    on<UserLastNameChanged>(_onUserLastNameChanged);
    on<UserPhoneChanged>(_onUserPhoneChanged);
    on<UserStatusChanged>(_onUserStatusChanged);
    on<UserPasswordChanged>(_onUserPasswordChanged);
    on<UserEmailChanged>(_onUserEmailChanged);
    on<UserLanguageChanged>(_onUserLanguageChanged);
    on<UserNotificationFrequencyChanged>(_onUserNotificationFrequencyChanged);
    on<UserRoleChanged>(_onUserRoleChanged);
    on<AddMembership>(_onAddMembership);
    on<RemoveMembership>(_onRemoveMembership);
    on<DeleteUser>(_onDeleteUser);
    on<SaveUserChanges>(_onSaveUserChanges);
    on<PrepareUserCreation>(_onPrepareUserCreation);
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<UserEditState> emit,
  ) async {
    emit(UserEditLoading());
    final userResult = await getUserByIdUseCase(event.userId);
    final associationsResult = await getAllAssociationsUseCase();

    userResult.fold(
      (failure) => emit(UserEditFailure(failure.message)),
      (user) {
        associationsResult.fold(
          (failure) => emit(UserEditFailure(failure.message)),
          (associations) => emit(UserEditLoaded(
            user: user,
            allAssociations: associations,
            isCreating: false, // Explicitly set to false when loading a user
          )),
        );
      },
    );
  }

  void _onUserFirstNameChanged(
      UserFirstNameChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(firstName: event.firstName)));
    }
  }

  void _onUserLastNameChanged(
      UserLastNameChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(lastName: event.lastName)));
    }
  }

  void _onUserPhoneChanged(
      UserPhoneChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(phone: event.phone)));
    }
  }

  void _onUserStatusChanged(
      UserStatusChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(status: event.status)));
    }
  }

  void _onUserPasswordChanged(
      UserPasswordChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(password: event.password)));
    }
  }

  void _onUserEmailChanged(
      UserEmailChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(email: event.email)));
    }
  }

  void _onUserLanguageChanged(
      UserLanguageChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(language: event.language)));
    }
  }

  void _onUserNotificationFrequencyChanged(
      UserNotificationFrequencyChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(
          user: currentState.user
              .copyWith(notificationFrequency: event.frequency)));
    }
  }

  void _onUserRoleChanged(UserRoleChanged event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      final newMemberships =
          Map<String, String>.from(currentState.user.memberships);
      newMemberships[event.associationId] = event.role;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(memberships: newMemberships)));
    }
  }

  void _onAddMembership(AddMembership event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      final newMemberships =
          Map<String, String>.from(currentState.user.memberships);
      newMemberships[event.associationId] = event.role;
      emit(currentState.copyWith(
          user: currentState.user.copyWith(memberships: newMemberships)));
    }
  }

  void _onRemoveMembership(
      RemoveMembership event, Emitter<UserEditState> emit) {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      final newMemberships =
          Map<String, String>.from(currentState.user.memberships)
            ..remove(event.associationId);
      emit(currentState.copyWith(
          user: currentState.user.copyWith(memberships: newMemberships)));
    }
  }

  Future<void> _onDeleteUser(
      DeleteUser event, Emitter<UserEditState> emit) async {
    if (state is UserEditLoaded) {
      final currentState = state as UserEditLoaded;
      emit(currentState.copyWith(isSaving: true));
      final result = await deleteUserUseCase(currentState.user.uid);
      emit(result.fold((failure) => UserEditFailure(failure.message),
          (_) => UserEditSuccess()));
    }
  }

  Future<void> _onSaveUserChanges(
      SaveUserChanges event, Emitter<UserEditState> emit) async {
    if (state is UserEditLoaded) {
      var currentState = state as UserEditLoaded;
      emit(currentState.copyWith(isSaving: true));
      if (currentState.isCreating) {
        // Lógica de creación
        final result = await createUserUseCase(currentState.user,
            password: currentState.user.password);
        emit(result.fold(
          (failure) => currentState.copyWith(
              isSaving: false, errorMessage: () => failure.message),
          (_) => UserEditSuccess(),
        ));
      } else {
        // Lógica de actualización
        final updatedUser = currentState.user
            .copyWith(configVersion: currentState.user.configVersion + 1);
        final result = await updateUserUseCase(
          user: updatedUser.toProfileEntity(),
          expectedDateUpdated: currentState.user.dateUpdated,
        );
        emit(result.fold((failure) {
          // Si es un fallo de concurrencia, emitimos un mensaje específico y permitimos refrescar
          return currentState.copyWith(
              isSaving: false, errorMessage: () => failure.message);
        }, (_) => UserEditSuccess()));
      }
    }
  }

  Future<void> _onPrepareUserCreation(
    PrepareUserCreation event,
    Emitter<UserEditState> emit,
  ) async {
    emit(UserEditLoading());
    // Necesitamos la lista de todas las asociaciones para el selector de membresías.
    final associationsResult = await getAllAssociationsUseCase();

    associationsResult.fold(
      (failure) => emit(UserEditFailure(
          'Error al preparar la creación de usuario: ${failure.message}')),
      (associations) => emit(UserEditLoaded(
        user: UserEntity.empty(),
        allAssociations: associations,
        isCreating: true,
      )),
    );
  }
}
