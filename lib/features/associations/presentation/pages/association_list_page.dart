import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';
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
    return Dismissible(
      key: Key(association.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Este método se llama DESPUÉS de que el elemento ha sido deslizado y eliminado de la vista.
        // La lógica de borrado real se inicia aquí, mostrando un SnackBar con opción de deshacer.
        final bloc = context.read<AssociationBloc>();

        SnackBarService.showSnackBar(
          l10n.associationDeletedSuccessfully,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () {
              // Si el usuario pulsa deshacer, se envía el evento correspondiente.
              bloc.add(UndoDeleteAssociation(association.id));
            },
          ),
        );
        // El borrado real se confirma si el SnackBar se cierra sin pulsar "Deshacer".
        // Esto se maneja en el BLoC o en el datasource con un delay.
      },
      confirmDismiss: (direction) async {
        // Mostrar un diálogo de confirmación antes de permitir el deslizamiento completo.
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
            false; // Si el diálogo se cierra sin seleccionar, no confirmar.
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(association.longName),
        subtitle: Text(association.shortName),
        onTap: () async {
          // Guardar referencias antes del 'await' para evitar usar el context de forma insegura.
          final navigator = Navigator.of(context);
          final bloc = context.read<AssociationBloc>();
          await navigator.pushNamed(RouteNames.associationEdit,
              arguments: association.id);
          bloc.add(LoadAssociations());
        },
      ),
    );
  }
}
