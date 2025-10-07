// lib/app/router/app_router.dart

import 'package:conectasoc/features/associations/presentation/pages/association_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:conectasoc/features/auth/presentation/presentation.dart';
import 'package:conectasoc/features/home/presentation/pages/pages.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/pages/pages.dart';
import 'package:conectasoc/injection_container.dart';

import 'route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );

      case RouteNames.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        );

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case RouteNames.localUserSetup:
        return MaterialPageRoute(
          builder: (_) => const LocalUserSetupPage(),
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case RouteNames.joinAssociation:
        return MaterialPageRoute(
          builder: (_) => const JoinAssociationPage(),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ProfileBloc>(),
            child: const ProfilePage(),
          ),
        );
      case RouteNames.associationsList:
        return MaterialPageRoute(builder: (_) => const AssociationListPage());
      case RouteNames.associationEdit:
        // TODO: Crear la página de edición de asociación
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Editar Asociación')),
                body: Center(
                    child: Text('ID de Asociación: ${settings.arguments}'))));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
