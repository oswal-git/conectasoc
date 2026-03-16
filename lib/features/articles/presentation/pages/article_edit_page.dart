import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:conectasoc/injection_container.dart';

import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/articles/presentation/widgets/widgets.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';

class ArticleEditPage extends StatelessWidget {
  final String? articleId;

  const ArticleEditPage({super.key, this.articleId});

  @override
  Widget build(BuildContext context) {
    // Resolver el shortName de la asociación activa consultando el HomeBloc,
    // que ya tiene la lista de asociaciones cargada en memoria.
    String associationShortName = '';
    if (articleId == null) {
      final authState = context.read<AuthBloc>().state;
      final homeState = context.read<HomeBloc>().state;
      if (authState is AuthAuthenticated && homeState is HomeLoaded) {
        final assocId = authState.currentMembership?.associationId;
        if (assocId != null) {
          associationShortName = homeState.associations
                  .firstWhereOrNull((a) => a.id == assocId)
                  ?.shortName ??
              '';
        }
      }
    }

    return BlocProvider(
      create: (context) => sl<ArticleEditBloc>(
        param1: context.read<AuthBloc>(),
      )..add(articleId == null
          ? PrepareArticleCreation(
              associationShortName:
                  associationShortName) // Si no hay ID, preparamos para crear
          : LoadArticleForEdit(articleId!)), // Si hay ID, cargamos para editar
      child: const ArticleEditView(),
    );
  }
}
