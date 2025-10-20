import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class LocalUserSetupState extends Equatable {
  const LocalUserSetupState();

  @override
  List<Object> get props => [];
}

class LocalUserSetupInitial extends LocalUserSetupState {}

class LocalUserSetupLoading extends LocalUserSetupState {}

class LocalUserSetupLoaded extends LocalUserSetupState {
  final List<AssociationEntity> associations;

  const LocalUserSetupLoaded(this.associations);

  @override
  List<Object> get props => [associations];
}

class LocalUserSetupError extends LocalUserSetupState {
  final String message;

  const LocalUserSetupError(this.message);

  @override
  List<Object> get props => [message];
}
