import 'package:conectasoc/app/router/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/associations/presentation/bloc/association_bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssociationListPage extends StatelessWidget {
  const AssociationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AssociationBloc>()..add(LoadAssociations()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.associations),
        ),
        body: const AssociationsListView(),
      ),
    );
  }
}

class AssociationsListView extends StatelessWidget {
  const AssociationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: l10n.search,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (query) {
              context.read<AssociationBloc>().add(SearchAssociations(query));
            },
          ),
        ),
        BlocBuilder<AssociationBloc, AssociationState>(
          builder: (context, state) {
            if (state is AssociationsLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SortButton(
                      label: l10n.name,
                      sortBy: SortBy.name,
                      currentState: state,
                    ),
                    _SortButton(
                      label: l10n.contact,
                      sortBy: SortBy.contact,
                      currentState: state,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: BlocBuilder<AssociationBloc, AssociationState>(
            builder: (context, state) {
              if (state is AssociationsLoading ||
                  state is AssociationsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AssociationsError) {
                return Center(child: Text(state.message));
              }
              if (state is AssociationsLoaded) {
                if (state.filteredAssociations.isEmpty) {
                  return Center(child: Text(l10n.noResultsFound));
                }
                return ListView.builder(
                  itemCount: state.filteredAssociations.length,
                  itemBuilder: (context, index) {
                    final assoc = state.filteredAssociations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              assoc.logoUrl != null && assoc.logoUrl!.isNotEmpty
                                  ? CachedNetworkImageProvider(assoc.logoUrl!)
                                  : null,
                          child: assoc.logoUrl == null || assoc.logoUrl!.isEmpty
                              ? const Icon(Icons.business, color: Colors.grey)
                              : null,
                        ),
                        title: Text(assoc.shortName),
                        subtitle: Text(
                            '${l10n.contact}: ${assoc.contactName} - ${assoc.phone}'),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              RouteNames.associationEdit,
                              arguments: assoc.id);
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final SortBy sortBy;
  final AssociationsLoaded currentState;

  const _SortButton({
    required this.label,
    required this.sortBy,
    required this.currentState,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentState.sortBy == sortBy;
    final IconData? icon = isActive
        ? (currentState.sortOrder == SortOrder.asc
            ? Icons.arrow_upward
            : Icons.arrow_downward)
        : null;

    return TextButton.icon(
      onPressed: () {
        context.read<AssociationBloc>().add(SortAssociations(sortBy));
      },
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox(width: 16),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
