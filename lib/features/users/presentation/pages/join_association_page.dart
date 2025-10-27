// lib/features/users/presentation/pages/join_association_page.dart

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinAssociationPage extends StatelessWidget {
  const JoinAssociationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => sl<UserBloc>(
        param1: context.read<AuthBloc>(), // Pasamos el AuthBloc del contexto
      )..add(LoadAvailableAssociations()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.joinAssociation),
        ),
        body: const JoinAssociationView(),
      ),
    );
  }
}

class JoinAssociationView extends StatelessWidget {
  const JoinAssociationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(listener: (context, state) {
      if (state is UserError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red));
      }
      if (state is UserUpdateSuccess) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('¡Te has unido a la asociación!'),
              backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    }, child: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is AvailableAssociationsLoading || state is UserInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AvailableAssociationsLoaded) {
          if (state.associations.isEmpty) {
            return const Center(
                child: Text('No hay nuevas asociaciones a las que unirse.'));
          }

          final authState = context.read<AuthBloc>().state as AuthAuthenticated;
          final isJoining =
              state is UserLoading; // Check if a join is in progress

          return ListView.builder(
            itemCount: state.associations.length,
            itemBuilder: (context, index) {
              final association = state.associations[index];
              return ListTile(
                title: Text(association.longName),
                subtitle: Text(association.shortName),
                trailing: isJoining
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.add),
                onTap: isJoining
                    ? null
                    : () => context.read<UserBloc>().add(
                        JoinAssociationRequested(
                            userId: authState.user.uid,
                            associationId: association.id)),
              );
            },
          );
        }
        return SizedBox.shrink();
      },
    ));
  }
}
