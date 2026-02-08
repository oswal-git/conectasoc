import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import 'package:conectasoc/app/router/route_names.dart';
import 'package:conectasoc/features/associations/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/widgets/widgets.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class HomePageViewWidget extends StatelessWidget {
  final bool canEdit;
  const HomePageViewWidget({super.key, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Si el usuario cambia (ej. al unirse o dejar una asociación),
        // recargamos los datos del HomeBloc para que tenga la lista de asociaciones actualizada.
        if (state is AuthAuthenticated) {
          context.read<HomeBloc>().add(LoadHomeData(
                user: state.user,
                membership: state.currentMembership,
              ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // El título ahora se construye aquí, con acceso a ambos BLoCs.
          title: _buildAppBarTitle(context, authState),
          actions: [
            if (canEdit)
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  final isEditMode =
                      state is HomeLoaded ? state.isEditMode : false;
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child:
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        isEditMode ? Icons.check_circle : Icons.edit_outlined,
                        key: ValueKey(isEditMode),
                        color: isEditMode ? Colors.green : null,
                      ),
                    ),
                    onPressed: () {
                      final user = authState is AuthAuthenticated
                          ? authState.user
                          : null;
                      context.read<HomeBloc>().add(ToggleEditMode(user: user));
                    },
                    tooltip: isEditMode
                        ? AppLocalizations.of(context).saveChanges
                        : AppLocalizations.of(context).editMode,
                  );
                },
              ),
          ],
        ),
        drawer: const HomeDrawer(), // El drawer se define aquí.
        body: const HomeViewWidget(),
        floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Obtenemos el estado de AuthBloc para acceder a la info del usuario.
            final authState = context.read<AuthBloc>().state;

            final bool canCreate = (state is HomeLoaded) &&
                (authState is AuthAuthenticated) &&
                state.isEditMode &&
                (authState.user.canEditContent);

            if (canCreate) {
              return FloatingActionButton(
                onPressed: () async {
                  await context.pushNamed(RouteNames.articleCreate);
                  if (context.mounted) {
                    final authState = context.read<AuthBloc>().state;
                    final homeState = context.read<HomeBloc>().state;
                    final user =
                        authState is AuthAuthenticated ? authState.user : null;
                    final isEditMode =
                        homeState is HomeLoaded ? homeState.isEditMode : false;
                    context.read<HomeBloc>().add(LoadHomeData(
                          user: user,
                          isEditMode: isEditMode,
                          forceReload: true,
                        ));
                  }
                },
                tooltip: AppLocalizations.of(context).createArticle,
                child: const Icon(Icons.add),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, AuthState authState) {
    final l10n = AppLocalizations.of(context);
    final homeState = context.watch<HomeBloc>().state;

    if (authState is AuthAuthenticated) {
      String associationName =
          l10n.all; // "Todas" Inicializar con un valor por defecto
      if (homeState is HomeLoaded) {
        // Si el superadmin no tiene membresía seleccionada, muestra "Ver todo"
        if (authState.user.isSuperAdmin &&
            authState.currentMembership == null) {
          associationName = l10n.all; // "Todas"
        } else {
          try {
            associationName = (homeState.associations.firstWhereOrNull(
                        (assoc) =>
                            assoc.id ==
                            authState.currentMembership?.associationId))
                    ?.shortName ??
                l10n.unknownAssociation;
          } catch (e) {
            associationName = l10n.unknownAssociation;
          }
        }
      }

      // El Superadmin siempre ve el dropdown, incluso si no tiene membresías.
      if (authState.user.isSuperAdmin ||
          authState.user.memberships.length > 1) {
        return InkWell(
          onTap: () => _showMembershipSwitcher(context, authState, homeState),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  associationName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        );
      }
      // Envolver también en una Row y Flexible para manejar el overflow
      // cuando solo hay una asociación.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text(associationName, overflow: TextOverflow.ellipsis))
        ],
      );
    }

    return Text(l10n.homePage);
  }

  void _showMembershipSwitcher(
      BuildContext context, AuthAuthenticated authState, HomeState homeState) {
    if (homeState is! HomeLoaded) return;

    if (!context.mounted) return;

    final authBloc = context.read<AuthBloc>();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Para el Superadmin, añadimos una opción "nula" para ver todo.
        Widget? superAdminAllOption;
        if (authState.user.isSuperAdmin) {
          superAdminAllOption = ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.public, color: Colors.grey),
            ),
            title: Text(l10n.all), // Corregido: Usar l10n
            trailing: authState.currentMembership == null
                ? const Icon(Icons.check_circle, color: Colors.blue, size: 28)
                : null,
            onTap: () {
              if (authState.currentMembership != null) {
                // El evento ahora acepta una membresía nula.
                authBloc.add(const AuthSwitchMembership(null));
              }
              Navigator.of(dialogContext).pop();
            },
          );
        }

        // Filtramos la membresía especial 'superadmin_access' para que no aparezca en la lista.
        final memberships = authState.user.memberships.entries
            .where((entry) => entry.key != 'superadmin_access')
            .toList();
        return AlertDialog(
          title: Text(l10n.changeAssociation),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount:
                  memberships.length + (superAdminAllOption != null ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (superAdminAllOption != null && index == 0) {
                  return superAdminAllOption;
                }
                final membershipIndex =
                    superAdminAllOption != null ? index - 1 : index;
                final membershipEntry = memberships[membershipIndex];
                final membership = MembershipEntity(
                  userId: authState.user.uid,
                  associationId: membershipEntry.key,
                  role: membershipEntry.value,
                );
                // Manejo seguro de currentMembership nulo.
                final isCurrent = membership.associationId ==
                    (authState.currentMembership?.associationId ?? '');

                AssociationEntity? association;
                try {
                  // Usamos firstWhereOrNull para evitar excepciones si la asociación no está en la lista.
                  association = homeState.associations.firstWhere(
                      (assoc) => assoc.id == membership.associationId);
                } catch (e) {
                  // Asociación no encontrada
                }

                final logoUrl = association?.logoUrl;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(logoUrl)
                        : null,
                    child: (logoUrl == null || logoUrl.isEmpty)
                        ? const Icon(Icons.group, color: Colors.grey)
                        : null,
                  ),
                  title: Text(association?.longName ?? l10n.unknownAssociation),
                  subtitle: Text(l10n.role(membership.role)),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle,
                          color: Colors.blue, size: 28)
                      : IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            // Obtenemos la referencia al BLoC ANTES de cerrar el diálogo.
                            final authBloc = context.read<AuthBloc>();
                            // Primero, cerramos el diálogo de selección de membresía.
                            Navigator.of(dialogContext).pop();
                            // Pasamos el BuildContext correcto que tiene acceso al HomeBloc.
                            // Usamos un post-frame callback para asegurar que el diálogo se ha cerrado.
                            SchedulerBinding.instance.addPostFrameCallback(
                                (_) => _confirmLeaveAssociation(
                                    context,
                                    authBloc,
                                    membership,
                                    association?.longName));
                          },
                        ),
                  onTap: () {
                    if (!isCurrent) {
                      authBloc.add(AuthSwitchMembership(membership));
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
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeaveAssociation(BuildContext context, AuthBloc authBloc,
      MembershipEntity membership, String? associationName) {
    final l10n = AppLocalizations.of(context);
    final nameToShow = associationName ?? l10n.unknownAssociation;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveAssociationConfirmationTitle),
        content: Text(l10n.leaveAssociationConfirmationMessage(nameToShow)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authBloc.add(AuthLeaveAssociation(membership));
            },
            child: Text(l10n.leave, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
