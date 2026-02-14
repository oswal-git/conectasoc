// lib/features/home/presentation/widgets/home_drawer.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context, state),
              _buildDrawerItem(
                context: context,
                icon: Icons.home_outlined,
                text: AppLocalizations.of(context).homePage,
                onTap: () {
                  GoRouter.of(context).pop();
                  GoRouter.of(context).go(RouteNames.home);
                },
              ),
              // Menú de Administración
              if (state is AuthAuthenticated) ...[
                // Las opciones de administración aparecen si el rol en la membresía
                // actual es 'admin' o si el usuario es 'superadmin'.
                if (state.user.isSuperAdmin ||
                    state.currentMembership?.role == 'admin') ...[
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.people_outline,
                    text: AppLocalizations.of(context).usersListTitle,
                    onTap: () {
                      GoRouter.of(context).pop();
                      GoRouter.of(context)
                          .push('${RouteNames.home}/${RouteNames.usersList}');
                    },
                  ),
                  // Si el usuario es superadmin global, puede ver todas las asociaciones.
                  // Si es solo admin, puede editar la suya.
                  if (state.user.isSuperAdmin)
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.business_outlined,
                      text: AppLocalizations.of(context).associationsListTitle,
                      onTap: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(context).go(
                            '${RouteNames.home}/${RouteNames.associationsList}');
                      },
                    )
                  else if (state.currentMembership?.associationId != null)
                    _buildDrawerItem(
                        context: context,
                        icon: Icons.business_outlined,
                        text: AppLocalizations.of(context).association,
                        onTap: () {
                          GoRouter.of(context).pop();
                          GoRouter.of(context).go(
                              '${RouteNames.home}/${RouteNames.associationEdit}/${state.currentMembership!.associationId}');
                        })
                  else
                    _buildDrawerItem(
                        context: context,
                        icon: Icons.business_outlined,
                        text: AppLocalizations.of(context).association,
                        onTap: () {
                          SnackBarService.showSnackBar(
                            AppLocalizations.of(context).noAssociationAvailable,
                            isError: true,
                          );
                        }),
                ],
                // Opción de Configuración solo para superadmin
                if (state.user.isSuperAdmin)
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    text: AppLocalizations.of(context).configuration,
                    onTap: () {
                      GoRouter.of(context).pop();
                      GoRouter.of(context)
                          .push('${RouteNames.home}/${RouteNames.settings}');
                    },
                  ),
              ],
              if (state is AuthAuthenticated)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  text: AppLocalizations.of(context).myProfile,
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context)
                        .push('${RouteNames.home}/${RouteNames.profile}');
                  },
                ),
              if (state is AuthAuthenticated)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.add_business_outlined,
                  text: AppLocalizations.of(context).joinAssociation,
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push(
                        '${RouteNames.home}/${RouteNames.joinAssociation}');
                  },
                ),
              const Divider(),
              _buildLoginLogoutButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final user = state.user;
      final membership = state.currentMembership;
      final accountEmailText = membership != null
          ? '${user.email} (${membership.role})'
          : user.email;

      return UserAccountsDrawerHeader(
        accountName: Text(user.fullName),
        accountEmail: Text(accountEmailText),
        currentAccountPicture: GestureDetector(
          onTap: () {
            GoRouter.of(context); // Cierra el drawer
            GoRouter.of(context)
                .push('${RouteNames.home}/${RouteNames.profile}');
          },
          child: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null ? Text(user.initials) : null,
          ),
        ),
        decoration: const BoxDecoration(
          color: Colors.blue,
        ),
      );
    }

    // Header para usuarios locales
    if (state is AuthLocalUser) {
      final user = state.localUser;

      return UserAccountsDrawerHeader(
        accountName: Text(user.displayName),
        accountEmail: Text(''),
        currentAccountPicture: CircleAvatar(
          backgroundImage: null,
          child: Text((user.displayName.substring(0,
                  user.displayName.length >= 3 ? 3 : user.displayName.length))
              .toUpperCase()),
        ),
        decoration: const BoxDecoration(
          color: Colors.blue,
        ),
      );
    }
    // Header para usuarios no logueados
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Text(
        'ConectaSoc',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildLoginLogoutButton(BuildContext context, AuthState state) {
    final l10n = AppLocalizations.of(context);

    if (state is AuthAuthenticated) {
      return _buildDrawerItem(
        context: context,
        icon: Icons.logout,
        text: l10n.logout,
        onTap: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(AuthSignOutRequested());
        },
      );
    }
    if (state is AuthLocalUser) {
      return _buildDrawerItem(
        context: context,
        icon: Icons.exit_to_app,
        text: l10n.exitReadOnlyMode,
        onTap: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(AuthDeleteLocalUser());
        },
      );
    }
    return _buildDrawerItem(
      context: context,
      icon: Icons.login,
      text: l10n.login,
      onTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go(RouteNames.welcome);
      },
    );
  }
}
