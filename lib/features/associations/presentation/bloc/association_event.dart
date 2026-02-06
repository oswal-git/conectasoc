import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class AssociationEvent extends Equatable {
  const AssociationEvent();

  @override
  List<Object> get props => [];
}

class LoadAssociations extends AssociationEvent {}

class RefreshAssociations extends AssociationEvent {}

class SearchAssociations extends AssociationEvent {
  final String query;
  const SearchAssociations(this.query);
  @override
  List<Object> get props => [query];
}

class SortAssociations extends AssociationEvent {
  final SortBy sortBy;
  const SortAssociations(this.sortBy);
  @override
  List<Object> get props => [sortBy];
}

class DeleteAssociation extends AssociationEvent {
  final String associationId;
  const DeleteAssociation(this.associationId);

  @override
  List<Object> get props => [associationId];
}

class UndoDeleteAssociation extends AssociationEvent {
  final String associationId;

  const UndoDeleteAssociation(this.associationId);

  @override
  List<Object> get props => [associationId];
}
