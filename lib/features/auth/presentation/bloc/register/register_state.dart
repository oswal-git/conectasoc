import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterDataLoaded extends RegisterState {
  final List<AssociationEntity> associations;
  final bool isFirstUser;
  const RegisterDataLoaded(
      {required this.associations, required this.isFirstUser});
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);
}
