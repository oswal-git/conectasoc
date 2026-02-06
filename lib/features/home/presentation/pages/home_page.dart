// lib/features/home/presentation/pages/home_page.dart

import 'package:conectasoc/features/home/presentation/widgets/home_page_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/home/presentation/bloc/bloc.dart';
import 'package:conectasoc/injection_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    UserEntity? user;
    MembershipEntity? membership;
    bool canEdit = false;

    if (authState is AuthAuthenticated) {
      user = authState.user;
      membership = authState.currentMembership;
      // La propiedad `canEditContent` ya encapsula la lógica de permisos.
      canEdit = user.canEditContent;
    }

    return BlocProvider(
      create: (context) => sl<HomeBloc>()
        ..add(LoadHomeData(
          user: user,
          membership: membership,
        )),
      child: HomePageViewWidget(canEdit: canEdit),
    );
  }
}
