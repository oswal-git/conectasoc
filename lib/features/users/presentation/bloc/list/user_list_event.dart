import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserListEvent {
  final String? associationId;
  const LoadUsers({this.associationId});

  @override
  List<Object?> get props => [associationId];
}

class RefreshUsers extends UserListEvent {
  final String? associationId;
  const RefreshUsers({this.associationId});

  @override
  List<Object?> get props => [associationId];
}

class SearchUsers extends UserListEvent {
  final String query;
  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class SortUsers extends UserListEvent {
  final UserSortOption sortOption;

  const SortUsers(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
