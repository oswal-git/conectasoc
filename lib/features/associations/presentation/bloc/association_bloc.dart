import 'package:conectasoc/features/associations/domain/usecases/delete_association_usecase.dart';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AssociationBloc extends Bloc<AssociationEvent, AssociationState> {
  final GetAllAssociationsUseCase getAllAssociationsUseCase;
  final DeleteAssociationUseCase deleteAssociationUseCase;

  AssociationBloc(
      {required this.getAllAssociationsUseCase,
      required this.deleteAssociationUseCase})
      : super(AssociationsInitial()) {
    on<LoadAssociations>(_onLoadAssociations);
    on<SearchAssociations>(_onSearchAssociations,
        transformer: debounce(const Duration(milliseconds: 300)));
    on<SortAssociations>(_onSortAssociations);
    on<DeleteAssociation>(_onDeleteAssociation);
  }

  Future<void> _onLoadAssociations(
    LoadAssociations event,
    Emitter<AssociationState> emit,
  ) async {
    emit(AssociationsLoading());
    final result = await getAllAssociationsUseCase();
    result.fold(
      (failure) => emit(AssociationsError(failure.message)),
      (associations) => emit(AssociationsLoaded(
        allAssociations: associations,
        filteredAssociations: associations,
      )),
    );
  }

  void _onSearchAssociations(
    SearchAssociations event,
    Emitter<AssociationState> emit,
  ) {
    final currentState = state;
    if (currentState is AssociationsLoaded) {
      final query = event.query.toLowerCase();
      final filtered = currentState.allAssociations.where((assoc) {
        return assoc.shortName.toLowerCase().contains(query) ||
            assoc.contactName!.toLowerCase().contains(query);
      }).toList();
      emit(currentState.copyWith(filteredAssociations: filtered));
    }
  }

  void _onSortAssociations(
    SortAssociations event,
    Emitter<AssociationState> emit,
  ) {
    final currentState = state;
    if (currentState is AssociationsLoaded) {
      final sorted =
          List<AssociationEntity>.from(currentState.filteredAssociations);
      final isAscending = currentState.sortOrder == SortOrder.asc;

      if (event.sortBy == currentState.sortBy && isAscending) {
        // Si se pulsa el mismo, invertimos el orden
        sorted.sort((a, b) => _compare(a, b, event.sortBy, false));
        emit(currentState.copyWith(
            filteredAssociations: sorted, sortOrder: SortOrder.desc));
      } else {
        sorted.sort((a, b) => _compare(a, b, event.sortBy, true));
        emit(currentState.copyWith(
            filteredAssociations: sorted,
            sortBy: event.sortBy,
            sortOrder: SortOrder.asc));
      }
    }
  }

  int _compare(AssociationEntity a, AssociationEntity b, SortBy sortBy,
      bool isAscending) {
    final int order = isAscending ? 1 : -1;
    switch (sortBy) {
      case SortBy.name:
        return a.shortName.compareTo(b.shortName) * order;
      case SortBy.contact:
        return a.contactName!.compareTo(b.contactName!) * order;
    }
  }

  Future<void> _onDeleteAssociation(
    DeleteAssociation event,
    Emitter<AssociationState> emit,
  ) async {
    final currentState = state;
    if (currentState is AssociationsLoaded) {
      final result = await deleteAssociationUseCase(event.associationId);

      result.fold(
        (failure) {
          // 1. Emitir el estado de fallo para que el listener (SnackBar) reaccione.
          emit(AssociationDeletionFailure(failure.message));
          // 2. Inmediatamente después, emitir el estado 'Loaded' para que el builder
          //    redibuje la lista. Mantenemos la lista que ya teníamos.
          emit(currentState);
        },
        (_) {
          // 3. Si el borrado es exitoso, emitir el estado de éxito.
          emit(AssociationDeletionSuccess());
          // 4. Volver a cargar la lista desde Firestore para reflejar el cambio.
          add(LoadAssociations());
        },
      );
    }
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
