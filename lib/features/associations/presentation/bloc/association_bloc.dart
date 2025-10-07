import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'association_event.dart';
part 'association_state.dart';

class AssociationBloc extends Bloc<AssociationEvent, AssociationState> {
  final GetAllAssociationsUseCase _getAllAssociationsUseCase;

  AssociationBloc(
      {required GetAllAssociationsUseCase getAllAssociationsUseCase})
      : _getAllAssociationsUseCase = getAllAssociationsUseCase,
        super(AssociationsInitial()) {
    on<LoadAssociations>(_onLoadAssociations);
    on<SearchAssociations>(_onSearchAssociations);
    on<SortAssociations>(_onSortAssociations);
  }

  Future<void> _onLoadAssociations(
    LoadAssociations event,
    Emitter<AssociationState> emit,
  ) async {
    emit(AssociationsLoading());
    final result = await _getAllAssociationsUseCase();
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
            assoc.contactName.toLowerCase().contains(query);
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
        return a.contactName.compareTo(b.contactName) * order;
    }
  }
}
