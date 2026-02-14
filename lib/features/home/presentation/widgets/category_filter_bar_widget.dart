import 'package:conectasoc/features/articles/domain/entities/category_entity.dart';
import 'package:conectasoc/features/articles/domain/entities/subcategory_entity.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_event_bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_state_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterBarWidget extends StatelessWidget {
  const CategoryFilterBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      // buildWhen para evitar reconstrucciones innecesarias
      buildWhen: (previous, current) {
        // Siempre reconstruir si cambiamos de estado
        if (previous.runtimeType != current.runtimeType) return true;

        // Si ambos son HomeLoaded, verificar cambios relevantes
        if (previous is HomeLoaded && current is HomeLoaded) {
          return previous.categories != current.categories ||
              previous.subcategories != current.subcategories ||
              previous.selectedCategory?.id != current.selectedCategory?.id ||
              previous.selectedSubcategory?.id !=
                  current.selectedSubcategory?.id;
        }

        return true;
      },
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox(height: 30);
        }

        final loadedState = state;

        debugPrint(
            'DEBUG Widget: selectedCategory=${loadedState.selectedCategory?.name}, subcategories=${loadedState.subcategories.length}');
        if (loadedState.subcategories.isNotEmpty) {
          debugPrint(
              'DEBUG Widget: First subcategory name=${loadedState.subcategories.first.name}');
        }

        // Si hay una categoría seleccionada, mostramos las subcategorías
        if (loadedState.selectedCategory != null) {
          return _buildSubcategoryFilterList(
            context: context,
            items: loadedState.subcategories,
            onItemSelected: (item) {
              if (loadedState.selectedSubcategory?.id == item.id) {
                // Si la subcategoría ya está seleccionada, la desactivamos
                // Dejando solo el filtro de categoría activo
                context
                    .read<HomeBloc>()
                    .add(CategorySelected(loadedState.selectedCategory!));
              } else {
                // Si no, seleccionamos la nueva subcategoría
                context.read<HomeBloc>().add(SubcategorySelected(item));
              }
            },
            onBack: () => context.read<HomeBloc>().add(ClearCategoryFilter()),
            selectedItem: loadedState.selectedSubcategory,
          );
        }

        // Si no, mostramos las categorías principales (sin flecha)
        return _buildCategoryFilterList(
          context: context,
          items: loadedState.categories,
          onItemSelected: (item) {
            if (loadedState.selectedCategory?.id == item.id) {
              // Si la categoría ya está seleccionada, la desactivamos
              context.read<HomeBloc>().add(ClearCategoryFilter());
            } else {
              // Si no, seleccionamos la nueva categoría
              context.read<HomeBloc>().add(CategorySelected(item));
            }
          },
          selectedItem: loadedState.selectedCategory,
        );
      },
    );
  }

  /// Widget para mostrar la lista de categorías principales (sin flecha)
  Widget _buildCategoryFilterList({
    required BuildContext context,
    required List<CategoryEntity> items,
    required Function(CategoryEntity) onItemSelected,
    CategoryEntity? selectedItem,
  }) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(item.name),
              selected: selectedItem?.id == item.id,
              onSelected: (_) => onItemSelected(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Widget para mostrar la lista de subcategorías con flecha de retroceso
  Widget _buildSubcategoryFilterList({
    required BuildContext context,
    required List<SubcategoryEntity> items,
    required Function(SubcategoryEntity) onItemSelected,
    required VoidCallback onBack,
    SubcategoryEntity? selectedItem,
  }) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Botón de flecha para volver atrás
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              avatar: const Icon(Icons.arrow_back, size: 18),
              label: const SizedBox.shrink(),
              onPressed: onBack,
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Lista de subcategorías
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(item.name),
                selected: selectedItem?.id == item.id,
                onSelected: (_) => onItemSelected(item),
              ),
            );
          }),
        ],
      ),
    );
  }
}
