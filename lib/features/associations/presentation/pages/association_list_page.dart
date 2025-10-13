import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/associations/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssociationListPage extends StatelessWidget {
  const AssociationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AssociationBloc>()..add(LoadAssociations()),
      child: const _AssociationListPageView(),
    );
  }
}

class _AssociationListPageView extends StatelessWidget {
  const _AssociationListPageView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.associationsListTitle),
      ),
      body: const AssociationListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Guardar referencias antes del 'await' para evitar usar el context de forma insegura.
          final navigator = Navigator.of(context);
          final bloc = context.read<AssociationBloc>();
          await navigator.pushNamed(RouteNames.associationEdit, arguments: '');
          bloc.add(LoadAssociations());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AssociationListView extends StatelessWidget {
  const AssociationListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AssociationBloc, AssociationState>(
      listener: (context, state) {
        if (state is AssociationDeletionSuccess) {
          SnackBarService.showSnackBar(l10n.associationDeletedSuccessfully);
        } else if (state is AssociationDeletionFailure) {
          SnackBarService.showSnackBar(
            _getTranslatedErrorMessage(state.message, l10n),
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state is AssociationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AssociationsLoaded) {
          if (state.filteredAssociations.isEmpty) {
            return Center(child: Text(l10n.noResultsFound));
          }
          return ListView.builder(
            itemCount: state.filteredAssociations.length,
            itemBuilder: (context, index) {
              final association = state.filteredAssociations[index];
              return _AssociationListItem(association: association);
            },
          );
        }
        if (state is AssociationsError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Initial State'));
      },
    );
  }

  String _getTranslatedErrorMessage(String key, AppLocalizations l10n) {
    if (key == 'associationHasUsersError') {
      return l10n.associationHasUsersError;
    }
    return key;
  }
}

class _AssociationListItem extends StatelessWidget {
  final AssociationEntity association;

  const _AssociationListItem({required this.association});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Dismissible(
        key: Key(association.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          final bloc = context.read<AssociationBloc>();
          bloc.add(DeleteAssociation(association.id));
        },
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: Text(l10n.deleteAssociation),
                  content: Text(
                      l10n.deleteAssociationConfirmation(association.longName)),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.cancel)),
                    TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(l10n.delete,
                            style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ) ??
              false;
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  association.logoUrl != null && association.logoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(association.logoUrl!)
                      : null,
              child: association.logoUrl == null || association.logoUrl!.isEmpty
                  ? Icon(Icons.business, color: Colors.grey[400])
                  : null,
            ),
            title: Text(association.longName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${association.shortName}\n${association.email}'),
            isThreeLine: true,
            onTap: () async {
              final navigator = Navigator.of(context);
              final bloc = context.read<AssociationBloc>();
              await navigator.pushNamed(RouteNames.associationEdit,
                  arguments: association.id);
              bloc.add(LoadAssociations());
            },
          ),
        ),
      ),
    );
  }
}
