import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:equatable/equatable.dart';

enum SortBy { name, contact }

enum SortOrder { asc, desc }

abstract class AssociationState extends Equatable {
  const AssociationState();

  @override
  List<Object> get props => [];
}

class AssociationsInitial extends AssociationState {}

class AssociationsLoading extends AssociationState {}

class AssociationsLoaded extends AssociationState {
  final List<AssociationEntity> allAssociations;
  final List<AssociationEntity> filteredAssociations;
  final SortBy sortBy;
  final SortOrder sortOrder;

  const AssociationsLoaded({
    required this.allAssociations,
    required this.filteredAssociations,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.asc,
  });

  AssociationsLoaded copyWith({
    List<AssociationEntity>? allAssociations,
    List<AssociationEntity>? filteredAssociations,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return AssociationsLoaded(
      allAssociations: allAssociations ?? this.allAssociations,
      filteredAssociations: filteredAssociations ?? this.filteredAssociations,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object> get props =>
      [allAssociations, filteredAssociations, sortBy, sortOrder];
}

class AssociationsError extends AssociationState {
  final String message;

  const AssociationsError(this.message);

  @override
  List<Object> get props => [message];
}

class AssociationDeletionSuccess extends AssociationState {
  const AssociationDeletionSuccess();
}

class AssociationDeletionFailure extends AssociationState {
  final String message;
  const AssociationDeletionFailure(this.message);
  @override
  List<Object> get props => [message];
}
