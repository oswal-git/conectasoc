// lib/features/users/presentation/bloc/user_event.dart

import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class JoinAssociationRequested extends UserEvent {
  final String userId;
  final String associationId;

  const JoinAssociationRequested(
      {required this.userId, required this.associationId});

  @override
  List<Object> get props => [userId, associationId];
}
