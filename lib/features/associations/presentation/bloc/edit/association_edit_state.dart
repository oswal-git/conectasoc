import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AssociationEditState extends Equatable {
  const AssociationEditState();

  @override
  List<Object?> get props => [];
}

class AssociationEditInitial extends AssociationEditState {}

class AssociationEditLoading extends AssociationEditState {}

class AssociationEditLoaded extends AssociationEditState {
  final AssociationEntity association;
  final bool isSaving;
  final bool isCreating;
  final String? newImagePath;
  final String? errorMessage;

  const AssociationEditLoaded({
    required this.association,
    this.isSaving = false,
    this.isCreating = false,
    this.newImagePath,
    this.errorMessage,
  });

  AssociationEditLoaded copyWith({
    AssociationEntity? association,
    bool? isSaving,
    bool? isCreating,
    String? newImagePath,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AssociationEditLoaded(
      association: association ?? this.association,
      isSaving: isSaving ?? this.isSaving,
      isCreating: isCreating ?? this.isCreating,
      newImagePath: newImagePath ?? this.newImagePath,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        association,
        isSaving,
        isCreating,
        newImagePath,
        errorMessage,
      ];
}

class AssociationDeleteSuccess extends AssociationEditState {}

class AssociationEditFailure extends AssociationEditState {
  final String message;
  const AssociationEditFailure(this.message);

  @override
  List<Object> get props => [message];
}
