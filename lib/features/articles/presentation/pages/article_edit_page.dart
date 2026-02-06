import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:conectasoc/injection_container.dart';

import 'package:conectasoc/features/articles/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/articles/presentation/widgets/widgets.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

class ArticleEditPage extends StatelessWidget {
  final String? articleId;

  const ArticleEditPage({super.key, this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ArticleEditBloc>(
        param1: context.read<AuthBloc>(),
      )..add(articleId == null
          ? PrepareArticleCreation() // Si no hay ID, preparamos para crear
          : LoadArticleForEdit(articleId!)), // Si hay ID, cargamos para editar
      child: const ArticleEditView(),
    );
  }
}
