import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? associationId;

    // Determinar qué usuarios cargar según el rol
    if (authState is AuthAuthenticated) {
      if (authState.currentMembership?.role != 'superadmin') {
        associationId = authState.currentMembership?.associationId;
      }
    }

    return BlocProvider(
      create: (context) =>
          sl<UserListBloc>()..add(LoadUsers(associationId: associationId)),
      child: const _UserListPageView(),
    );
  }
}

class _UserListPageView extends StatelessWidget {
  const _UserListPageView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.users),
        actions: [
          BlocBuilder<UserListBloc, UserListState>(
            builder: (context, state) {
              if (state is! UserListLoaded) return const SizedBox.shrink();
              return PopupMenuButton<UserSortOption>(
                icon: const Icon(Icons.sort),
                onSelected: (sortOption) {
                  context.read<UserListBloc>().add(SortUsers(sortOption));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: UserSortOption.name, child: Text(l10n.name)),
                  PopupMenuItem(
                      value: UserSortOption.email, child: Text(l10n.email)),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.search,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                context.read<UserListBloc>().add(SearchUsers(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UserListBloc, UserListState>(
              builder: (context, state) {
                if (state is UserListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UserListLoaded) {
                  if (state.filteredUsers.isEmpty) {
                    return Center(child: Text(l10n.noResultsFound));
                  }
                  return ListView.builder(
                    itemCount: state.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = state.filteredUsers[index];
                      return _UserListItem(user: user);
                    },
                  );
                }
                if (state is UserListError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context)
              .push('${RouteNames.home}/${RouteNames.userEdit}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserEntity user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage:
                user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? Text(user.initials)
                : null,
          ),
          title: Text(user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.email),
          onTap: () {
            GoRouter.of(context)
                .push('${RouteNames.home}/${RouteNames.userEdit}/${user.uid}');
          },
        ),
      ),
    );
  }
}
