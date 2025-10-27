import 'dart:typed_data';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
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
  final Uint8List? newImageBytes;
  final String? errorMessage;
  final bool isCreating;

  const AssociationEditLoaded({
    required this.association,
    this.associationUsers = const [],
    this.isSaving = false,
    this.isCreating = false,
    this.newImageBytes,
    this.errorMessage,
  });

  AssociationEditLoaded copyWith({
    AssociationEntity? association,
    List<UserEntity>? associationUsers,
    bool? isSaving,
    bool? isCreating,
    Uint8List? newImageBytes,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AssociationEditLoaded(
      association: association ?? this.association,
      associationUsers: associationUsers ?? this.associationUsers,
      isSaving: isSaving ?? this.isSaving,
      isCreating: isCreating ?? this.isCreating,
      newImageBytes: newImageBytes ?? this.newImageBytes,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        association,
        isSaving,
        isCreating,
        newImageBytes,
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
