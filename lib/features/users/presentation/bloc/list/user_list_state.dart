import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

enum UserSortOption {
  name,
  email,
}

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object> get props => [];
}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<UserEntity> allUsers;
  final List<UserEntity> filteredUsers;
  final UserSortOption sortOption;

  const UserListLoaded({
    required this.allUsers,
    required this.filteredUsers,
    this.sortOption = UserSortOption.name,
  });

  @override
  List<Object> get props => [allUsers, filteredUsers, sortOption];

  UserListLoaded copyWith({
    List<UserEntity>? allUsers,
    List<UserEntity>? filteredUsers,
    UserSortOption? sortOption,
  }) {
    return UserListLoaded(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class UserListError extends UserListState {
  final String message;
  const UserListError(this.message);
}
