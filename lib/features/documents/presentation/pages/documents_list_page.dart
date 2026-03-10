import 'package:conectasoc/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/features/documents/presentation/bloc/document_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/document_event_bloc.dart';
import 'package:conectasoc/features/documents/presentation/bloc/document_state_bloc.dart';
import 'package:conectasoc/features/documents/presentation/widgets/document_thumbnail_widget.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class DocumentListPage extends StatelessWidget {
  const DocumentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Documentos')),
        body: const Center(child: Text('Debe iniciar sesión')),
      );
    }

    final user = authState.user;
    final associationId =
        user.isSuperAdmin ? null : authState.currentMembership?.associationId;

    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state as AuthAuthenticated;
        final user = authState.user;
        final membership = authState.currentMembership;

        return sl<DocumentBloc>()
          ..add(LoadDocuments(
            associationId: associationId,
            isSuperAdmin: user.isSuperAdmin,
            userAssociationId: membership?.associationId,
            userRole: membership?.role,
          ));
      },
      child: const DocumentListView(),
    );
  }
}

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  bool _showSearch = false;
  bool _showFilters = false;

  /// Navega a la pantalla de upload y refresca la lista si se subió un documento.
  Future<void> _goToUpload() async {
    final result = await context
        .push<bool>('${RouteNames.home}/${RouteNames.documentUpload}');

    // Si la página de upload devuelve true (upload exitoso), refrescar
    if (result == true && mounted && context.mounted) {
      context.read<DocumentBloc>().add(const RefreshDocuments());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documentList),
        actions: [
          // Icono búsqueda
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
            ),
            tooltip: _showSearch ? 'Ocultar búsqueda' : 'Buscar',
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          // Icono filtros
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            tooltip: _showFilters ? 'Ocultar filtros' : 'Filtrar',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          // Icono subir documento
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: l10n.uploadDocuments,
            onPressed: _goToUpload,
          ),
        ],
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentInitial || state is DocumentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DocumentBloc>().add(
                          const RefreshDocuments(),
                        ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DocumentLoaded) {
            return Column(
              children: [
                // ── Búsqueda (independiente) ──────────────────────────
                if (_showSearch) _buildSearchBar(context),

                // ── Filtros categoría/subcategoría (independiente) ─────
                if (_showFilters) _buildCategoryFilters(context, state, l10n),

                // ── Lista de documentos ───────────────────────────────
                Expanded(
                  child: state.filteredDocuments.isEmpty
                      ? _buildEmptyState(context, l10n)
                      : _buildDocumentList(context, state),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

// ── Barra de búsqueda ────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.searchDocument,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          isDense: true,
        ),
        onChanged: (query) {
          context.read<DocumentBloc>().add(DocumentQueryChanged(query));
        },
      ),
    );
  }

  // ── Filtros categoría / subcategoría ─────────────────────────────
  Widget _buildCategoryFilters(
    BuildContext context,
    DocumentLoaded state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppDropdownWidget<String>(
                  label: l10n.category,
                  value: state.selectedCategoryId,
                  isExpanded: true,
                  variant: AppDropdownVariant.dense,
                  items: [
                    AppDropdownItem(
                      value: null,
                      label: '— ${l10n.category} —',
                    ),
                    ...state.categories.map(
                      (c) => AppDropdownItem(
                        value: c.id,
                        label: c.name,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context
                        .read<DocumentBloc>()
                        .add(DocumentCategoryFilterChanged(value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppDropdownWidget<String>(
                  value: state.selectedSubcategoryId,
                  label: l10n.subcategory,
                  variant: AppDropdownVariant.dense,
                  isExpanded: true,
                  items: [
                    AppDropdownItem(
                      value: null,
                      label: '— ${l10n.subcategory} —',
                    ),
                    ...state.subcategories.map(
                      (s) => AppDropdownItem(
                        value: s.id,
                        label: s.name,
                      ),
                    ),
                  ],
                  onChanged: state.selectedCategoryId == null
                      ? null
                      : (value) {
                          context
                              .read<DocumentBloc>()
                              .add(DocumentSubcategoryFilterChanged(value));
                        },
                ),
              ),
            ],
          ),
          if (state.hasActiveFilters) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.filter_list, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${state.filteredDocuments.length} resultado${state.filteredDocuments.length == 1 ? "" : "s"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context
                      .read<DocumentBloc>()
                      .add(const DocumentFiltersCleared()),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar filtros',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildDocumentList(BuildContext context, DocumentLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DocumentBloc>().add(const RefreshDocuments());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredDocuments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = state.filteredDocuments[index];
          return _DocumentListTile(document: doc);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.noDocumentsFound,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goToUpload,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.uploadDocuments),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tile individual de documento
// ─────────────────────────────────────────────

class _DocumentListTile extends StatelessWidget {
  final DocumentEntity document;

  const _DocumentListTile({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () async {
          final result = await context.push<bool>(
            '${RouteNames.home}/${RouteNames.documentView}'
                .replaceFirst(':documentId', document.id),
          );
          // Si la página de upload devuelve true (upload exitoso), refrescar
          if (result == true && context.mounted) {
            context.read<DocumentBloc>().add(const RefreshDocuments());
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              DocumentThumbnailWidget(
                document: document,
                width: 56,
                height: 70,
              ),
              const SizedBox(width: 14),

              // Información
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
                    const SizedBox(height: 6),

                    // Nombre de archivo + tamaño
                    Text(
                      '${document.fileName}  ·  ${document.formattedFileSize}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Badges
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

              // Flecha
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
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
        color: color.withAlpha(12),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
