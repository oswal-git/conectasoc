// lib/features/home/presentation/widgets/app_drawer.dart

import 'package:conectasoc/app/router/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                text: AppLocalizations.of(context)!.homePage,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed(RouteNames.home),
              ),
              if (_shouldShowAdminMenu(state)) ...[
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_outline,
                  text: AppLocalizations.of(context)!.users,
                  onTap: () {
                    // TODO: Navegar a la pantalla de usuarios
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.business_outlined,
                  text: AppLocalizations.of(context)!.associations,
                  onTap: () {
                    // TODO: Navegar a la pantalla de asociaciones
                  },
                ),
              ],
              if (state is AuthAuthenticated)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  text: AppLocalizations.of(context)!.myProfile,
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteNames.profile);
                  },
                ),
              if (state is AuthAuthenticated)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.add_business_outlined,
                  text: AppLocalizations.of(context)!.joinAssociation,
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteNames.joinAssociation);
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

  bool _shouldShowAdminMenu(AuthState state) {
    if (state is AuthAuthenticated) {
      return state.user.isSuperAdmin || state.user.isAdmin;
    }
    return false;
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
            Navigator.of(context).pop(); // Cierra el drawer
            Navigator.of(context).pushNamed(RouteNames.profile);
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
    // Header para usuarios no logueados o locales
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
      onTap: () {
        Navigator.of(context).pop(); // Cierra el drawer
        onTap();
      },
    );
  }

  Widget _buildLoginLogoutButton(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      return _buildDrawerItem(
        context: context,
        icon: Icons.logout,
        text: AppLocalizations.of(context)!.logout,
        onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
      );
    }
    return _buildDrawerItem(
      context: context,
      icon: Icons.login,
      text: AppLocalizations.of(context)!.login,
      onTap: () => Navigator.of(context)
          .pushNamedAndRemoveUntil(RouteNames.welcome, (route) => false),
    );
  }
}
