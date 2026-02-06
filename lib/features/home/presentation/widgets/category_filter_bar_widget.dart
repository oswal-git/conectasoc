import 'package:conectasoc/features/articles/domain/entities/category_entity.dart';
import 'package:conectasoc/features/articles/domain/entities/subcategory_entity.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_event_bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/home_state_bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterBarWidget extends StatelessWidget {
  const CategoryFilterBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      // buildWhen para evitar reconstrucciones innecesarias
      buildWhen: (previous, current) =>
          previous is! HomeLoaded ||
          (current is HomeLoaded &&
              (previous.categories != current.categories ||
                  previous.subcategories != current.subcategories ||
                  previous.selectedCategory != current.selectedCategory ||
                  previous.selectedSubcategory != current.selectedSubcategory)),
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox(height: 50);
        }

        final loadedState = state;

        // Si hay una categoría seleccionada, mostramos las subcategorías
        if (loadedState.selectedCategory != null) {
          return _buildFilterList(
            context: context,
            items: loadedState.subcategories,
            onItemSelected: (item) => context
                .read<HomeBloc>()
                .add(SubcategorySelected(item as SubcategoryEntity)),
            onClear: () => context.read<HomeBloc>().add(ClearCategoryFilter()),
            selectedItem: loadedState.selectedSubcategory,
            clearText: AppLocalizations.of(context).all,
          );
        }

        // Si no, mostramos las categorías principales
        return _buildFilterList(
          context: context,
          items: loadedState.categories,
          onItemSelected: (item) =>
              context.read<HomeBloc>().add(CategorySelected(item)),
          selectedItem: loadedState.selectedCategory,
        );
      },
    );
  }

  Widget _buildFilterList({
    required BuildContext context,
    required List<CategoryEntity> items,
    required Function(CategoryEntity) onItemSelected,
    CategoryEntity? selectedItem,
    VoidCallback? onClear,
    String? clearText,
  }) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          if (onClear != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(clearText!),
                selected: selectedItem == null,
                onSelected: (_) => onClear(),
              ),
            ),
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
