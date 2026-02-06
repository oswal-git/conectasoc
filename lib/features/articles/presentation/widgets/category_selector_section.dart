import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class CategorySelectorSection extends StatelessWidget {
  final bool isEnabled;
  final String categoryId;
  final String subcategoryId;
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subcategories;
  final AppLocalizations l10n;

  const CategorySelectorSection({
    super.key,
    required this.isEnabled,
    required this.categoryId,
    required this.subcategoryId,
    required this.categories,
    required this.subcategories,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              key: Key('category_$categoryId'),
              initialValue: categoryId.isEmpty ? null : categoryId,
              decoration: InputDecoration(labelText: l10n.category),
              items: categories.toSet().map((CategoryEntity category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<ArticleEditBloc>().add(CategoryChanged(value));
                }
              },
              validator: (value) =>
                  value == null || value.isEmpty ? l10n.requiredField : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              key: Key('subcategory_$subcategoryId'),
              initialValue: subcategoryId.isEmpty ? null : subcategoryId,
              decoration: InputDecoration(labelText: l10n.subcategory),
              items: subcategories.toSet().map((SubcategoryEntity subcategory) {
                return DropdownMenuItem<String>(
                  value: subcategory.id,
                  child:
                      Text(subcategory.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<ArticleEditBloc>()
                      .add(SubcategoryChanged(value));
                }
              },
              validator: (value) =>
                  value == null || value.isEmpty ? l10n.requiredField : null,
            ),
          ),
        ],
      ),
    );
  }
}
