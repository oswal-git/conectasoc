import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class UserEditState extends Equatable {
  const UserEditState();

  @override
  @override
  List<Object?> get props => [];
}

class UserEditInitial extends UserEditState {}

class UserEditLoading extends UserEditState {}

class UserEditLoaded extends UserEditState {
  final bool isSaving;
  final String? errorMessage;
  final UserEntity user;
  final List<AssociationEntity> allAssociations;
  final bool isCreating;

  const UserEditLoaded({
    required this.user,
    required this.allAssociations,
    this.isSaving = false,
    this.errorMessage,
    this.isCreating = false,
  });

  UserEditLoaded copyWith({
    UserEntity? user,
    List<AssociationEntity>? allAssociations,
    bool? isSaving,
    ValueGetter<String?>? errorMessage,
    bool? isCreating,
  }) {
    return UserEditLoaded(
      user: user ?? this.user,
      allAssociations: allAssociations ?? this.allAssociations,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props =>
      [user, isSaving, errorMessage, allAssociations, isCreating];
}

class UserEditSuccess extends UserEditState {}

class UserEditFailure extends UserEditState {
  final String message;

  const UserEditFailure(this.message);

  @override
  @override
  List<Object?> get props => [message];
}
