import 'package:equatable/equatable.dart';

abstract class LocalUserSetupEvent extends Equatable {
  const LocalUserSetupEvent();

  @override
  List<Object> get props => [];
}

class LoadAssociations extends LocalUserSetupEvent {}
