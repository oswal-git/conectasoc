// lib/app/router/app_router.dart

import 'dart:async';

import 'package:conectasoc/features/articles/presentation/pages/pages.dart';
import 'package:conectasoc/features/associations/presentation/pages/pages.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/pages/pages.dart';
import 'package:conectasoc/features/home/presentation/pages/pages.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/pages/pages.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:conectasoc/injection_container.dart';
import 'package:logger/logger.dart';
import 'route_names.dart';

class AppRouter {
  final AuthBloc authBloc;

  final logger = Logger();

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.localUserSetup,
        builder: (context, state) => const LocalUserSetupPage(),
      ),
      GoRoute(
        path: RouteNames.verification,
        builder: (context, state) {
          // Obtener el email del estado de AuthBloc
          final authState = context.read<AuthBloc>().state;
          String email = '';

          if (authState is AuthNeedsVerification) {
            email = authState.email;
          } else if (state.extra != null && state.extra is String) {
            email = state.extra as String;
          }

          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'joinAssociation', // Ruta relativa a /home
            builder: (context, state) => const JoinAssociationPage(),
          ),
          GoRoute(
            path: 'profile', // Ruta relativa a /home
            builder: (context, state) => BlocProvider.value(
              value: sl<ProfileBloc>(),
              child: const ProfilePage(),
            ),
          ),
          GoRoute(
            path: 'associations', // Ruta relativa a /home
            builder: (context, state) => const AssociationListPage(),
          ),
          GoRoute(
            path: 'associations/edit', // Ruta relativa a /home
            builder: (context, state) => AssociationEditPage(associationId: ''),
          ),
          GoRoute(
            path: 'associations/edit/:id', // Ruta relativa a /home
            builder: (context, state) =>
                AssociationEditPage(associationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'users-list', // Ruta relativa a /home
            builder: (context, state) => const UserListPage(),
          ),
          GoRoute(
            path: 'user-edit', // Ruta relativa a /home
            builder: (context, state) => UserEditPage(userId: ''),
          ),
          GoRoute(
            path: 'user-edit/:id', // Ruta relativa a /home
            builder: (context, state) =>
                UserEditPage(userId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'articles/create',
            name: RouteNames.articleCreate,
            builder: (context, state) => const ArticleEditPage(),
          ),
          GoRoute(
            name: RouteNames.articleDetail,
            path: '/articles/:articleId',
            builder: (context, state) {
              final articleId = state.pathParameters['articleId']!;
              return ArticleDetailPage(articleId: articleId);
            },
          ),
          GoRoute(
            path: 'settings',
            name: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      // Mover la ruta de edición fuera de /home para que `pushNamed` funcione como se espera.
      GoRoute(
        path: '/articles/:id/edit',
        name: RouteNames.articleEdit,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ArticleEditPage(articleId: id);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final authState = authBloc.state;
      final location = state.uri.toString();
      logger.t("➡️ AppRouter-redirect: authState = ${authState.runtimeType}");
      logger.t("➡️ AppRouter-redirect: location = $location");

      // Esperar a que el estado se resuelva
      // /*********************************************************
      // /************  AuthInitial  AuthLoading *********
      // /*********************************************************
      if (authState is AuthInitial || authState is AuthLoading) {
        logger.t(
            "1 ➡️ AppRouter-redirect: authState is AuthInitial || authState is AuthLoading -> null");
        return null; // Wait for authState to be resolved
      }

      // /*********************************************************
      // /************  AuthNeedsVerification *********
      // /*********************************************************
      // CRÍTICO: Manejar AuthNeedsVerification PRIMERO
      if (authState is AuthNeedsVerification) {
        logger.t("2 ➡️ AppRouter-redirect: authState is AuthNeedsVerification");
        if (location != RouteNames.verification) {
          logger.t(
              "2.1 ➡️ AppRouter-redirect: authState is AuthNeedsVerification -> $location != ${RouteNames.verification} -> ${RouteNames.verification}");
          return RouteNames.verification;
        }
        logger.t(
            "2.2 ➡️ AppRouter-redirect: authState is AuthNeedsVerification -> $location == ${RouteNames.verification} -> null");
        return null;
      }

      // /****************************************************************************
      // /************  AuthAuthenticated  AuthLocalUser AuthUnauthenticated *********
      // /****************************************************************************
      // Desde splash, redirigir según el estado
      if (location == RouteNames.splash) {
        logger.t("3 ➡️ AppRouter-redirect: $location == ${RouteNames.splash}");
        if (authState is AuthAuthenticated || authState is AuthLocalUser) {
          logger.t(
              "3.1 ➡️ AppRouter-redirect: authState is AuthAuthenticated || authState is AuthLocalUser -> ${RouteNames.home}");
          return RouteNames.home;
        } else if (authState is AuthUnauthenticated) {
          logger.t(
              "3.2 ➡️ AppRouter-redirect: authState is AuthUnauthenticated -> ${RouteNames.welcome}");
          return RouteNames.welcome;
        }
      }

      // /****************************************************************************
      // /************  AuthAuthenticated  AuthLocalUser *********
      // /****************************************************************************
      // Usuario autenticado no puede acceder a páginas de auth
      if (authState is AuthAuthenticated || authState is AuthLocalUser) {
        logger.t(
            "4 ➡️ AppRouter-redirect: authState is AuthAuthenticated || authState is AuthLocalUser");
        final authRoutes = [
          RouteNames.welcome,
          RouteNames.login,
          RouteNames.register,
          RouteNames.verification,
        ];
        if (authRoutes.contains(location)) {
          logger.t(
              "4.1 ➡️ AppRouter-redirect: authState is AuthAuthenticated || authState is AuthLocalUser -> !authRoutes.contains(location) = ${!authRoutes.contains(location)}");
          return RouteNames.home;
        }
      }

      // /****************************************************************************
      // /************   AuthUnauthenticated *********
      // /****************************************************************************
      // Usuario no autenticado solo puede acceder a páginas públicas
      if (authState is AuthUnauthenticated) {
        logger.t("5 ➡️ AppRouter-redirect: authState is AuthUnauthenticated");
        final publicRoutes = [
          RouteNames.welcome,
          RouteNames.login,
          RouteNames.register,
          RouteNames.localUserSetup,
          RouteNames.splash,
        ];

        if (!publicRoutes.contains(location)) {
          logger.t(
              "5.1 ➡️ AppRouter-redirect: !publicRoutes.contains(location) = ${!publicRoutes.contains(location)}");
          logger.t(
              "5.2 ➡️ AppRouter-redirect: !publicRoutes.contains(location) = ${!publicRoutes.contains(location)} -> ${RouteNames.welcome}");
          return RouteNames.welcome;
        }
      }

      logger.t("6 ➡️ AppRouter-redirect: final -> null");
      return null; // No redirection needed
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
