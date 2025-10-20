import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final UserEntity? user;
  final MembershipEntity? membership;

  const LoadHomeData({this.user, this.membership});

  @override
  List<Object?> get props => [user, membership];
}

class ToggleEditMode extends HomeEvent {}

class SearchQueryChanged extends HomeEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class CategorySelected extends HomeEvent {
  final CategoryEntity category;

  const CategorySelected(this.category);

  @override
  List<Object> get props => [category];
}

class SubcategorySelected extends HomeEvent {
  final SubcategoryEntity subcategory;

  const SubcategorySelected(this.subcategory);

  @override
  List<Object> get props => [subcategory];
}

class ClearCategoryFilter extends HomeEvent {}
