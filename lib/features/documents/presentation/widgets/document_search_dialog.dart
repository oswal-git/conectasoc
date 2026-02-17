import 'package:conectasoc/features/documents/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

/// Abre el diálogo de búsqueda y devuelve el [DocumentEntity] seleccionado,
/// o null si el usuario cancela.
Future<DocumentEntity?> showDocumentSearchDialog({
  required BuildContext context,
  required String? associationId,
}) {
  return showDialog<DocumentEntity>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => sl<DocumentSearchBloc>()
        ..add(InitializeDocumentSearch(associationId: associationId)),
      child: const _DocumentSearchDialogContent(),
    ),
  );
}

class _DocumentSearchDialogContent extends StatefulWidget {
  const _DocumentSearchDialogContent();

  @override
  State<_DocumentSearchDialogContent> createState() =>
      _DocumentSearchDialogContentState();
}

class _DocumentSearchDialogContentState
    extends State<_DocumentSearchDialogContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabecera ──────────────────────────────
            _buildHeader(context, l10n),

            // ── Barra de búsqueda ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _buildSearchBar(context, l10n),
            ),

            // ── Filtros de categoría / subcategoría ───
            BlocBuilder<DocumentSearchBloc, DocumentSearchState>(
              buildWhen: (prev, curr) =>
                  curr is DocumentSearchLoaded &&
                  (prev is! DocumentSearchLoaded ||
                      (prev).categories != (curr).categories ||
                      (prev).selectedCategoryId != curr.selectedCategoryId),
              builder: (context, state) {
                if (state is! DocumentSearchLoaded) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildFilters(context, state, l10n),
                );
              },
            ),

            // ── Chip de filtros activos ───────────────
            BlocBuilder<DocumentSearchBloc, DocumentSearchState>(
              buildWhen: (prev, curr) =>
                  curr is DocumentSearchLoaded &&
                  (prev is! DocumentSearchLoaded ||
                      (prev).hasActiveFilters != (curr).hasActiveFilters),
              builder: (context, state) {
                if (state is! DocumentSearchLoaded || !state.hasActiveFilters) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: _buildActiveFiltersBar(context, state, l10n),
                );
              },
            ),

            const Divider(height: 16),

            // ── Lista de resultados ───────────────────
            Expanded(
              child: BlocBuilder<DocumentSearchBloc, DocumentSearchState>(
                builder: (context, state) {
                  if (state is DocumentSearchLoading ||
                      state is DocumentSearchInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is DocumentSearchError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is DocumentSearchLoaded) {
                    return _buildDocumentList(context, state, l10n);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Pie: cancelar ────────────────────────
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widgets internos
  // ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.searchDocument,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: l10n.searchDocument,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context
                      .read<DocumentSearchBloc>()
                      .add(const DocumentSearchQueryChanged(''));
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {}); // para mostrar/ocultar el botón clear
        context
            .read<DocumentSearchBloc>()
            .add(DocumentSearchQueryChanged(value));
      },
    );
  }

  Widget _buildFilters(
    BuildContext context,
    DocumentSearchLoaded state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Filtro categoría
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: state.selectedCategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.category,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            hint: Text(l10n.category, style: const TextStyle(fontSize: 13)),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('— ${l10n.category} —',
                    style: const TextStyle(fontSize: 13)),
              ),
              ...state.categories.map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
            onChanged: (value) {
              context
                  .read<DocumentSearchBloc>()
                  .add(DocumentSearchCategoryChanged(value));
            },
          ),
        ),
        const SizedBox(width: 8),

        // Filtro subcategoría
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: state.selectedSubcategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.subcategory,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            hint: Text(l10n.subcategory, style: const TextStyle(fontSize: 13)),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('— ${l10n.subcategory} —',
                    style: const TextStyle(fontSize: 13)),
              ),
              ...state.subcategories.map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
            onChanged: state.selectedCategoryId == null
                ? null
                : (value) {
                    context
                        .read<DocumentSearchBloc>()
                        .add(DocumentSearchSubcategoryChanged(value));
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersBar(
    BuildContext context,
    DocumentSearchLoaded state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.filter_list, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${state.filteredDocuments.length} resultado${state.filteredDocuments.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            _searchController.clear();
            setState(() {});
            context
                .read<DocumentSearchBloc>()
                .add(const DocumentSearchFiltersCleared());
          },
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Limpiar filtros', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8)),
        ),
      ],
    );
  }

  Widget _buildDocumentList(
    BuildContext context,
    DocumentSearchLoaded state,
    AppLocalizations l10n,
  ) {
    if (state.filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              l10n.noDocumentsFound,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DocumentSearchBloc>().add(const DocumentSearchRefreshed());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.filteredDocuments.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final doc = state.filteredDocuments[index];
          return _DocumentResultTile(
            document: doc,
            onTap: () => Navigator.of(context).pop(doc),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tile individual de documento en la lista
// ─────────────────────────────────────────────

class _DocumentResultTile extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const _DocumentResultTile({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            DocumentThumbnailWidget(
              document: document,
              width: 52,
              height: 66,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  Text(
                    document.descDoc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Nombre de archivo + tamaño
                  Text(
                    '${document.fileName}  ·  ${document.formattedFileSize}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Badges: extensión + descarga
                  Row(
                    children: [
                      _Badge(
                        label: document.fileExtension.toUpperCase(),
                        color: _extensionColor(document.fileExtension),
                      ),
                      if (!document.canDownload) ...[
                        const SizedBox(width: 6),
                        _Badge(
                          label: 'Sin descarga',
                          color: Colors.grey,
                          icon: Icons.lock_outline,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Flecha seleccionar
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _extensionColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade600;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(120),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
