import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<CategoryEntity> categories;
  final Map<String, List<SubcategoryEntity>> subcategoriesMap;
  final bool isProcessing;
  final String? assocId;

  const SettingsLoaded({
    required this.categories,
    required this.subcategoriesMap,
    this.isProcessing = false,
    this.assocId,
  });

  SettingsLoaded copyWith({
    List<CategoryEntity>? categories,
    Map<String, List<SubcategoryEntity>>? subcategoriesMap,
    bool? isProcessing,
    String? assocId,
  }) {
    return SettingsLoaded(
      categories: categories ?? this.categories,
      subcategoriesMap: subcategoriesMap ?? this.subcategoriesMap,
      isProcessing: isProcessing ?? this.isProcessing,
      assocId: assocId ?? this.assocId,
    );
  }

  @override
  List<Object?> get props =>
      [categories, subcategoriesMap, isProcessing, assocId];
}

class SettingsOpSuccess extends SettingsState {
  final String message;
  const SettingsOpSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
