import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
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
  final List<UserEntity> associationUsers;
  final bool isSaving;
  final bool isCreating;
  final String? newImagePath;
  final String? errorMessage;

  const AssociationEditLoaded({
    required this.association,
    this.associationUsers = const [],
    this.isSaving = false,
    this.isCreating = false,
    this.newImagePath,
    this.errorMessage,
  });

  AssociationEditLoaded copyWith({
    AssociationEntity? association,
    List<UserEntity>? associationUsers,
    bool? isSaving,
    bool? isCreating,
    String? newImagePath,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AssociationEditLoaded(
      association: association ?? this.association,
      associationUsers: associationUsers ?? this.associationUsers,
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

class AssociationEditSuccess extends AssociationEditState {}

class AssociationDeleteSuccess extends AssociationEditState {}

class AssociationEditFailure extends AssociationEditState {
  final String message;
  const AssociationEditFailure(this.message);

  @override
  List<Object> get props => [message];
}
