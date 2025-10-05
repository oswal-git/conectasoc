// lib/features/home/presentation/pages/home_page.dart

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/widgets/association_provider.dart';
import 'package:conectasoc/features/home/presentation/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AssociationProvider(
          child: Scaffold(
            appBar: AppBar(
              title: _buildAppBarTitle(context, state),
            ),
            drawer: const AppDrawer(),
            body: const Center(
              child: Text('No hay artículos por ahora.'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(BuildContext context, AuthState state) {
    final allAssociations = AssociationProvider.of(context);

    if (state is AuthAuthenticated && state.currentMembership != null) {
      // Si el usuario tiene más de una membresía, muestra un selector
      if (state.user.memberships.length > 1) {
        AssociationEntity? currentAssociation;
        try {
          currentAssociation = allAssociations.firstWhere(
              (assoc) => assoc.id == state.currentMembership!.associationId);
        } catch (e) {
          // No se encontró la asociación, se manejará con el null check
        }
        final currentAssociationName = currentAssociation?.shortName;

        return InkWell(
          onTap: () => _showMembershipSwitcher(context, state),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentAssociationName ?? 'Inicio'),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        );
      } else {
        // Si solo tiene una, muestra el título "Inicio"
        return const Text('Inicio');
      }
    }
    // Para usuarios locales o sin membresía
    return const Text('Inicio');
  }

  void _showMembershipSwitcher(
      BuildContext context, AuthAuthenticated authState) {
    final allAssociations = AssociationProvider.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambiar de Asociación'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: authState.user.memberships.length,
              itemBuilder: (context, index) {
                final membership = authState.user.memberships[index];
                final isCurrent = membership.associationId ==
                    authState.currentMembership!.associationId;
                AssociationEntity? association;
                try {
                  association = allAssociations.firstWhere(
                      (assoc) => assoc.id == membership.associationId);
                } catch (e) {
                  // No se encontró la asociación
                }
                final associationName = association?.longName;

                return ListTile(
                  title: Text(associationName ?? 'Asociación desconocida'),
                  subtitle: Text('Rol: ${membership.role}'),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    if (!isCurrent) {
                      // Dispara el evento para cambiar de membresía
                      context
                          .read<AuthBloc>()
                          .add(AuthSwitchMembership(membership));
                    }
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
