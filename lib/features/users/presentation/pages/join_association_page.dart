// lib/features/users/presentation/pages/join_association_page.dart

import 'package:conectasoc/features/associations/domain/usecases/usecases.dart';
import 'package:conectasoc/features/auth/domain/domain.dart';
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
      create: (context) => sl<UserBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.joinAssociation),
        ),
        body: const JoinAssociationView(),
      ),
    );
  }
}

class JoinAssociationView extends StatefulWidget {
  const JoinAssociationView({super.key});

  @override
  State<JoinAssociationView> createState() => _JoinAssociationViewState();
}

class _JoinAssociationViewState extends State<JoinAssociationView> {
  List<AssociationEntity> _allAssociations = [];
  List<AssociationEntity> _availableAssociations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final userMemberships = authState.user.memberships.keys.toSet();

    final result = await sl<GetAllAssociationsUseCase>()();
    result.fold(
      (failure) {
        // Handle error
      },
      (associations) {
        setState(() {
          _allAssociations = associations;
          _availableAssociations = _allAssociations
              .where((assoc) => !userMemberships.contains(assoc.id))
              .toList();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableAssociations.isEmpty) {
      return const Center(
          child: Text('No hay nuevas asociaciones a las que unirse.'));
    }

    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
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
      },
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state as AuthAuthenticated;
        return ListView.builder(
          itemCount: _availableAssociations.length,
          itemBuilder: (context, index) {
            final association = _availableAssociations[index];
            return ListTile(
              title: Text(association.longName),
              subtitle: Text(association.shortName),
              trailing: state is UserLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.add),
              onTap: state is UserLoading
                  ? null
                  : () {
                      context.read<UserBloc>().add(JoinAssociationRequested(
                            userId: authState.user.uid,
                            associationId: association.id,
                          ));
                    },
            );
          },
        );
      },
    );
  }
}
