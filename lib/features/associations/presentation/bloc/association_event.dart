part of 'association_bloc.dart';

abstract class AssociationEvent extends Equatable {
  const AssociationEvent();

  @override
  List<Object> get props => [];
}

class LoadAssociations extends AssociationEvent {}

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
