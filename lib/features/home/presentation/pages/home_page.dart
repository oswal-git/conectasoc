// lib/features/home/presentation/pages/home_page.dart

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/widgets/widgets.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AssociationProviderWidget(
          child: Builder(
            builder: (innerContext) => Scaffold(
              appBar: AppBar(
                title: _buildAppBarTitle(innerContext, state),
              ),
              drawer: const HomeDrawer(),
              body: const Center(
                child: Text(''), // El texto se mostrará dentro del provider
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(BuildContext context, AuthState state) {
    final l10n = AppLocalizations.of(context)!;
    final allAssociations = AssociationProviderWidget.of(context);

    String? associationId;
    if (state is AuthAuthenticated) {
      associationId = state.currentMembership?.associationId;
    } else if (state is AuthLocalUser) {
      associationId = state.localUser.associationId;
    }

    AssociationEntity? currentAssociation;
    if (associationId != null) {
      try {
        currentAssociation =
            allAssociations.firstWhere((assoc) => assoc.id == associationId);
      } catch (e) {
        // No se encontró la asociación, se manejará con el null check
      }
    }

    if (state is AuthAuthenticated && state.currentMembership != null) {
      // Si el usuario tiene más de una membresía, muestra un selector
      if (state.user.memberships.length > 1) {
        return InkWell(
          onTap: () => _showMembershipSwitcher(context, state),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentAssociation?.shortName ?? l10n.homePage),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        );
      }
    }
    // Para usuarios locales o usuarios con una sola membresía
    return Text(currentAssociation?.shortName ?? l10n.homePage);
  }

  void _showMembershipSwitcher(
      BuildContext context, AuthAuthenticated authState) {
    final allAssociations = AssociationProviderWidget.of(context);
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        final memberships = authState.user.memberships.entries.toList();
        return AlertDialog(
          title: Text(l10n.changeAssociation),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: memberships.length,
              itemBuilder: (context, index) {
                final membershipEntry = memberships[index];
                final membership = MembershipEntity(
                    userId: authState.user.uid,
                    associationId: membershipEntry.key,
                    role: membershipEntry.value);
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

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: association?.logoUrl != null &&
                                association!.logoUrl!.isNotEmpty
                            ? NetworkImage(association.logoUrl!)
                            : null,
                        child: association?.logoUrl == null ||
                                association!.logoUrl!.isEmpty
                            ? const Icon(Icons.group, color: Colors.grey)
                            : null,
                      ),
                      title: Text(associationName ?? l10n.unknownAssociation),
                      subtitle: Text(l10n.role(membership.role)),
                      trailing: isCurrent
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        if (!isCurrent) {
                          // Dispara el evento para cambiar de membresía
                          authBloc.add(AuthSwitchMembership(membership));
                        }
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    // Solo mostrar opción de abandonar si tiene más de una membresía,
                    // no es la actual y el rol no es admin
                    if (memberships.length > 1 &&
                        !isCurrent &&
                        membership.role != 'admin')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.exit_to_app,
                                color: Colors.red),
                            label: Text(
                              l10n.leaveAssociation,
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext)
                                  .pop(); // Cerrar el switcher
                              _showLeaveConfirmation(
                                  context, membership, associationName ?? '');
                            },
                          ),
                        ),
                      ),
                    if (index < memberships.length - 1)
                      const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveConfirmation(BuildContext context, MembershipEntity membership,
      String associationName) {
    final authBloc = context.read<AuthBloc>();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveAssociationConfirmationTitle),
        content:
            Text(l10n.leaveAssociationConfirmationMessage(associationName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              authBloc.add(AuthLeaveAssociation(membership));
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              l10n.leave,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
