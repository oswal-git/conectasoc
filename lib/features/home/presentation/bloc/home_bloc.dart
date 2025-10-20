import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/associations/domain/usecases/get_all_associations_usecase.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetArticlesUseCase getArticlesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;
  final GetAllAssociationsUseCase getAllAssociationsUseCase;

  HomeBloc({
    required this.getArticlesUseCase,
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
    required this.getAllAssociationsUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ToggleEditMode>(_onToggleEditMode);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<ClearCategoryFilter>(_onClearCategoryFilter);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final results = await Future.wait([
        getArticlesUseCase(user: event.user, membership: event.membership),
        getCategoriesUseCase(),
        getAllAssociationsUseCase(),
      ]);

      final articlesResult = results[0];
      final categoriesResult = results[1];
      final associationsResult = results[2];

      // Extraer valores o lanzar error
      final articles = articlesResult.fold(
          (failure) => throw failure, (data) => data) as List<ArticleEntity>;
      final categories = categoriesResult.fold(
          (failure) => throw failure, (data) => data) as List<CategoryEntity>;
      final associations =
          associationsResult.fold((failure) => throw failure, (data) => data)
              as List<AssociationEntity>;

      emit(HomeLoaded(
        allArticles: articles,
        filteredArticles: articles,
        categories: categories,
        associations: associations,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isEditMode: !currentState.isEditMode));
    }
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filtered = currentState.allArticles.where((article) {
        final query = event.query.toLowerCase();
        return article.title.toLowerCase().contains(query) ||
            article.abstractContent.toLowerCase().contains(query);
      }).toList();
      emit(currentState.copyWith(filteredArticles: filtered));
    }
  }

  void _onCategorySelected(CategorySelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Cargar subcategorías para la categoría seleccionada
      getSubcategoriesUseCase(event.category.id).then((result) {
        result.fold(
          (failure) => emit(HomeError(failure.message)),
          (subcategories) {
            final filtered = currentState.allArticles
                .where((article) => article.categoryId == event.category.id)
                .toList();
            emit(currentState.copyWith(
              filteredArticles: filtered,
              selectedCategory: event.category,
              subcategories: subcategories,
              selectedSubcategory: null, // Limpiar subcategoría
            ));
          },
        );
      });
    }
  }

  void _onSubcategorySelected(
      SubcategorySelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filtered = currentState.allArticles
          .where((article) => article.subcategoryId == event.subcategory.id)
          .toList();
      emit(currentState.copyWith(
        filteredArticles: filtered,
        selectedSubcategory: event.subcategory,
      ));
    }
  }

  void _onClearCategoryFilter(
      ClearCategoryFilter event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        filteredArticles: currentState.allArticles,
        selectedCategory: null,
        selectedSubcategory: null,
      ));
    }
  }
}
