import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/presentation/bloc/edit/association_edit_event.dart';
import 'package:conectasoc/features/associations/presentation/bloc/edit/association_edit_state.dart';
import 'package:conectasoc/features/users/domain/usecases/get_users_by_association_usecase.dart';

class AssociationEditBloc
    extends Bloc<AssociationEditEvent, AssociationEditState> {
  final CreateAssociationUseCase createAssociation;
  final GetAssociationByIdUseCase getAssociationById;
  final GetUsersByAssociationUseCase getUsersByAssociation;
  final UpdateAssociationUseCase updateAssociation;
  final DeleteAssociationUseCase deleteAssociation;

  AssociationEditBloc({
    required this.createAssociation,
    required this.getAssociationById,
    required this.getUsersByAssociation,
    required this.updateAssociation,
    required this.deleteAssociation,
  }) : super(AssociationEditInitial()) {
    on<LoadAssociationDetails>(_onLoadAssociationDetails);
    on<ShortNameChanged>(_onShortNameChanged);
    on<LongNameChanged>(_onLongNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<ContactNameChanged>(_onContactNameChanged);
    on<ContactPersonChanged>(_onContactPersonChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<LogoChanged>(_onLogoChanged);
    on<SaveChanges>(_onSaveChanges);
    on<CreateAssociation>(_onCreateAssociation);
    on<DeleteCurrentAssociation>(_onDeleteAssociation);
  }

  Future<void> _onLoadAssociationDetails(
    LoadAssociationDetails event,
    Emitter<AssociationEditState> emit,
  ) async {
    emit(AssociationEditLoading());
    if (event.associationId.isEmpty) {
      // Modo Creación: inicializamos con una entidad vacía
      emit(AssociationEditLoaded(
          association: AssociationEntity.empty(), isCreating: true));
    } else {
      // Modo Edición
      // 1. Cargar los detalles de la asociación
      final associationResult = await getAssociationById(event.associationId);

      // Manejar el caso de fallo al cargar la asociación
      if (associationResult.isLeft()) {
        final failure = (associationResult as Left).value as Failure;
        emit(AssociationEditFailure(failure.message));
        return;
      }

      final association = (associationResult as Right).value;

      // 2. Cargar los usuarios de esa asociación
      final usersResult = await getUsersByAssociation(association.id);

      // 3. Emitir el estado final con toda la información
      emit(usersResult.fold(
        (failure) => AssociationEditLoaded(
            association: association, errorMessage: failure.message),
        (users) => AssociationEditLoaded(
            association: association, associationUsers: users),
      ));
    }
  }

  void _onShortNameChanged(
      ShortNameChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(
        association:
            currentState.association.copyWith(shortName: event.shortName),
      ));
    }
  }

  void _onLongNameChanged(
      LongNameChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(
        association:
            currentState.association.copyWith(longName: event.longName),
      ));
    }
  }

  void _onEmailChanged(EmailChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(
        association: currentState.association.copyWith(email: event.email),
      ));
    }
  }

  void _onContactNameChanged(
      ContactNameChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(
        association:
            currentState.association.copyWith(contactName: event.contactName),
      ));
    }
  }

  void _onContactPersonChanged(
      ContactPersonChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      final selectedUser = currentState.associationUsers
          .firstWhere((user) => user.uid == event.userId);

      // Al cambiar el usuario de contacto, actualizamos también los campos de texto
      // para una mejor experiencia de usuario, pero siguen siendo editables.
      emit(currentState.copyWith(
          association: currentState.association.copyWith(
              contactUserId: selectedUser.uid,
              contactName: selectedUser.fullName,
              email: selectedUser.email,
              phone: selectedUser.phone)));
    }
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(
        association: currentState.association.copyWith(phone: event.phone),
      ));
    }
  }

  void _onLogoChanged(LogoChanged event, Emitter<AssociationEditState> emit) {
    if (state is AssociationEditLoaded) {
      emit((state as AssociationEditLoaded)
          .copyWith(newImageBytes: event.imageBytes));
    }
  }

  Future<void> _onSaveChanges(
      SaveChanges event, Emitter<AssociationEditState> emit) async {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(isSaving: true, clearErrorMessage: true));

      final result = await updateAssociation(
        association: currentState.association,
        logoBytes: currentState.newImageBytes,
        expectedDateUpdated: currentState.association.dateUpdated,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(
              isSaving: false, errorMessage: failure.message));
        },
        (updatedAssociation) {
          emit(AssociationEditSuccess());
          // Volvemos al estado cargado para que la UI no se quede "atascada" en éxito
          emit(currentState.copyWith(
              isSaving: false,
              association: updatedAssociation,
              newImageBytes: null));
        },
      );
    }
  }

  Future<void> _onCreateAssociation(
      CreateAssociation event, Emitter<AssociationEditState> emit) async {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(isSaving: true, clearErrorMessage: true));

      final result = await createAssociation(
        shortName: currentState.association.shortName,
        longName: currentState.association.longName,
        email: currentState.association.email ?? '',
        contactName: currentState.association.contactName ?? '',
        phone: currentState.association.phone ?? '',
        // El creatorId es nulo cuando crea un superadmin.
        // El contactUserId se toma del estado actual.
        contactUserId: currentState.association.contactUserId,
        logoBytes: currentState.newImageBytes,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(
              isSaving: false, errorMessage: failure.message));
        },
        (newAssociation) {
          emit(AssociationEditSuccess());
          // Después de crear, pasamos a modo edición con la nueva asociación y sus usuarios
          add(LoadAssociationDetails(newAssociation.id));
        },
      );
    }
  }

  Future<void> _onDeleteAssociation(DeleteCurrentAssociation event,
      Emitter<AssociationEditState> emit) async {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      // Reutilizamos 'isSaving' para mostrar un indicador de carga
      emit(currentState.copyWith(isSaving: true, clearErrorMessage: true));

      final result = await deleteAssociation(currentState.association.id);

      result.fold(
        (failure) {
          // Si falla, volvemos al estado anterior pero con un mensaje de error
          emit(currentState.copyWith(
              isSaving: false, errorMessage: failure.message));
        },
        (_) {
          emit(AssociationDeleteSuccess());
        },
      );
    }
  }
}
