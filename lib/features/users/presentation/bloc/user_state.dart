// lib/features/users/presentation/bloc/user_state.dart

import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserUpdateSuccess extends UserState {}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class AvailableAssociationsLoading extends UserState {}

class AvailableAssociationsLoaded extends UserState {
  final List<AssociationEntity> associations;
  const AvailableAssociationsLoaded(this.associations);
}
