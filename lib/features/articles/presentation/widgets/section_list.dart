import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'article_section_editor.dart';

class SectionList extends StatelessWidget {
  final bool isEditingEnabled;

  const SectionList({
    super.key,
    required this.isEditingEnabled,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: Only rebuild the list structure if the number of sections or their order changes.
    // We select a list of IDs which is enough to detect these changes.
    return BlocSelector<ArticleEditBloc, ArticleEditState, List<String>>(
      selector: (state) {
        if (state is ArticleEditLoaded) {
          return state.article.sections.map((s) => s.id).toList();
        }
        return [];
      },
      builder: (context, sectionIds) {
        if (sectionIds.isEmpty) return const SizedBox.shrink();

        return ReorderableListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          primary: false,
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return BlocProvider.value(
              value: context.read<ArticleEditBloc>(),
              child: child,
            );
          },
          itemCount: sectionIds.length,
          itemBuilder: (context, index) {
            final sectionId = sectionIds[index];
            // We get the section data inside the item builder.
            // The ArticleSectionEditor itself is already optimized with BlocSelector.
            final state =
                context.read<ArticleEditBloc>().state as ArticleEditLoaded;
            final section = state.article.sections[index];

            return ArticleSectionEditor(
              key: ValueKey(sectionId),
              section: section,
              index: index,
              isEditingEnabled: isEditingEnabled,
              showDragHandle: sectionIds.length > 1,
              onRemove: () =>
                  context.read<ArticleEditBloc>().add(RemoveSection(sectionId)),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            context
                .read<ArticleEditBloc>()
                .add(ReorderSectionsEvent(oldIndex, newIndex));
          },
        );
      },
    );
  }
}
