// lib/app/router/app_router.dart

import 'dart:async';

import 'package:conectasoc/features/articles/presentation/pages/pages.dart';
import 'package:conectasoc/features/associations/presentation/pages/pages.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/auth/presentation/pages/pages.dart';
import 'package:conectasoc/features/auth/presentation/pages/verification_page.dart';
import 'package:conectasoc/features/home/presentation/pages/pages.dart';
import 'package:conectasoc/features/users/presentation/bloc/bloc.dart';
import 'package:conectasoc/features/users/presentation/pages/pages.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:conectasoc/injection_container.dart';
import 'route_names.dart';

class AppRouter {
  final AuthBloc authBloc;

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
        builder: (context, state) =>
            VerificationPage(email: state.extra as String),
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
            path: 'articles/:id/edit',
            name: RouteNames.articleEdit,
            builder: (context, state) {
              final id = state.pathParameters['id'];
              // Podríamos añadir una comprobación de que el id no es nulo
              return ArticleEditPage(articleId: id);
            },
          ),
          GoRoute(
            name: RouteNames.articleDetail,
            path: '/articles/:articleId',
            builder: (context, state) {
              final articleId = state.pathParameters['articleId']!;
              return ArticleDetailPage(articleId: articleId);
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final authState = authBloc.state;
      final location = state.uri.toString();

      if (authState is AuthInitial || authState is AuthLoading) {
        return null; // Wait for authState to be resolved
      }

      if (location == RouteNames.splash) {
        if (authState is AuthAuthenticated || authState is AuthLocalUser) {
          return RouteNames.home;
        } else if (authState is AuthUnauthenticated) {
          return RouteNames.welcome;
        } else if (authState is AuthNeedsVerification) {
          return RouteNames.verification;
        }
      }

      if (authState is AuthAuthenticated || authState is AuthLocalUser) {
        if (location == RouteNames.welcome ||
            location == RouteNames.login ||
            location == RouteNames.register) {
          return RouteNames.home;
        }
      }

      if (authState is AuthUnauthenticated) {
        if (location != RouteNames.welcome &&
            location != RouteNames.login &&
            location != RouteNames.register &&
            location != RouteNames.localUserSetup &&
            location != RouteNames.splash) {
          return RouteNames.welcome;
        }
      }

      if (authState is AuthNeedsVerification) {
        return RouteNames.verification;
      }

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
