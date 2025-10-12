import 'dart:io';

import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/presentation/bloc/edit/association_edit_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/associations/presentation/bloc/edit/association_edit_state.dart';

class AssociationEditBloc
    extends Bloc<AssociationEditEvent, AssociationEditState> {
  final CreateAssociationUseCase createAssociation;
  final GetAssociationByIdUseCase getAssociationById;
  final UpdateAssociationUseCase updateAssociation;
  final DeleteAssociationUseCase deleteAssociation;

  AssociationEditBloc({
    required this.createAssociation,
    required this.getAssociationById,
    required this.updateAssociation,
    required this.deleteAssociation,
  }) : super(AssociationEditInitial()) {
    on<LoadAssociationDetails>(_onLoadAssociationDetails);
    on<ShortNameChanged>(_onShortNameChanged);
    on<LongNameChanged>(_onLongNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<ContactNameChanged>(_onContactNameChanged);
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
      final result = await getAssociationById(event.associationId);
      result.fold(
        (failure) => emit(AssociationEditFailure(failure.message)),
        (association) => emit(AssociationEditLoaded(association: association)),
      );
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
          .copyWith(newImagePath: event.imagePath));
    }
  }

  Future<void> _onSaveChanges(
      SaveChanges event, Emitter<AssociationEditState> emit) async {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(isSaving: true, clearErrorMessage: true));

      final result = await updateAssociation(
        association: currentState.association,
        newLogoFile: currentState.newImagePath != null
            ? File(currentState.newImagePath!)
            : null,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(
              isSaving: false, errorMessage: failure.message));
        },
        (updatedAssociation) {
          emit(currentState.copyWith(
              isSaving: false,
              association: updatedAssociation,
              newImagePath: ''));
        },
      );
    }
  }

  Future<void> _onCreateAssociation(
      CreateAssociation event, Emitter<AssociationEditState> emit) async {
    if (state is AssociationEditLoaded) {
      final currentState = state as AssociationEditLoaded;
      emit(currentState.copyWith(isSaving: true, clearErrorMessage: true));

      // El creatorId no es relevante aquí, ya que la regla de seguridad
      // permitirá la creación si el usuario es superadmin.
      // Pasamos un valor temporal que no se usará.
      final result = await createAssociation(
        shortName: currentState.association.shortName,
        longName: currentState.association.longName,
        email: currentState.association.email ?? '',
        contactName: currentState.association.contactName ?? '',
        phone: currentState.association.phone ?? '',
        creatorId: 'superadmin_creation',
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(
              isSaving: false, errorMessage: failure.message));
        },
        (newAssociation) {
          // Después de crear, pasamos a modo edición con la nueva asociación
          emit(AssociationEditLoaded(
              association: newAssociation, isSaving: false));
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
