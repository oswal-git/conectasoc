import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetSubcategoriesUseCase _getSubcategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final CreateSubcategoryUseCase _createSubcategoryUseCase;
  final UpdateSubcategoryUseCase _updateSubcategoryUseCase;
  final DeleteSubcategoryUseCase _deleteSubcategoryUseCase;

  SettingsBloc({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetSubcategoriesUseCase getSubcategoriesUseCase,
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
    required CreateSubcategoryUseCase createSubcategoryUseCase,
    required UpdateSubcategoryUseCase updateSubcategoryUseCase,
    required DeleteSubcategoryUseCase deleteSubcategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _getSubcategoriesUseCase = getSubcategoriesUseCase,
        _createCategoryUseCase = createCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase,
        _createSubcategoryUseCase = createSubcategoryUseCase,
        _updateSubcategoryUseCase = updateSubcategoryUseCase,
        _deleteSubcategoryUseCase = deleteSubcategoryUseCase,
        super(SettingsInitial()) {
    on<LoadSettingsData>(_onLoadSettingsData);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<AddSubcategory>(_onAddSubcategory);
    on<UpdateSubcategory>(_onUpdateSubcategory);
    on<DeleteSubcategory>(_onDeleteSubcategory);
  }

  Future<void> _onLoadSettingsData(
      LoadSettingsData event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final categoriesResult = await _getCategoriesUseCase();
      await categoriesResult.fold(
        (failure) async => emit(SettingsError(failure.message)),
        (categories) async {
          final subcategoriesMap = <String, List<SubcategoryEntity>>{};
          for (final category in categories) {
            final subcategoriesResult =
                await _getSubcategoriesUseCase(category.id);
            subcategoriesResult.fold(
              (failure) => emit(SettingsError(
                  'Error cargando subcategorías')), // Simplified error
              (subcategories) {
                subcategoriesMap[category.id] = subcategories;
              },
            );
          }
          emit(SettingsLoaded(
              categories: categories, subcategoriesMap: subcategoriesMap));
        },
      );
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<SettingsState> emit) async {
    final result = await _createCategoryUseCase(event.name);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;
    final category =
        currentState.categories.firstWhere((cat) => cat.id == event.id);
    final result =
        await _updateCategoryUseCase(category.copyWith(name: event.newName));
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<SettingsState> emit) async {
    final result = await _deleteCategoryUseCase(event.id);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }

  Future<void> _onAddSubcategory(
      AddSubcategory event, Emitter<SettingsState> emit) async {
    final result =
        await _createSubcategoryUseCase(event.name, event.categoryId);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }

  Future<void> _onUpdateSubcategory(
      UpdateSubcategory event, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;
    SubcategoryEntity? subcategory;
    for (var sublist in currentState.subcategoriesMap.values) {
      try {
        subcategory = sublist.firstWhere((sub) => sub.id == event.id);
        break;
      } catch (e) {
        // Not in this list, continue
      }
    }

    if (subcategory == null) {
      emit(const SettingsError('Subcategoría no encontrada'));
      return;
    }

    final result = await _updateSubcategoryUseCase(
        subcategory.copyWith(name: event.newName));
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }

  Future<void> _onDeleteSubcategory(
      DeleteSubcategory event, Emitter<SettingsState> emit) async {
    final result = await _deleteSubcategoryUseCase(event.id);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => add(LoadSettingsData()),
    );
  }
}
