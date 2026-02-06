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
  final bool isLoading;

  const UserListLoaded({
    required this.allUsers,
    required this.filteredUsers,
    this.sortOption = UserSortOption.name,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [allUsers, filteredUsers, sortOption, isLoading];

  UserListLoaded copyWith({
    List<UserEntity>? allUsers,
    List<UserEntity>? filteredUsers,
    UserSortOption? sortOption,
    bool? isLoading,
  }) {
    return UserListLoaded(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserListError extends UserListState {
  final String message;
  const UserListError(this.message);
}
