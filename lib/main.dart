// lib/main.dart

import 'dart:async';
import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:conectasoc/core/constants/globals.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'firebase_options.dart';

// Inyección de dependencias
import 'injection_container.dart';

// BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';

// Router
import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/services/snackbar_service.dart';
import 'package:conectasoc/services/notification_service.dart';
import 'package:conectasoc/core/utils/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar dependencias (Clean Architecture)
  await init();

  // Inicializar servicio de notificaciones
  await sl<NotificationService>().init();

  runApp(const ConectaSocApp());
}

class ConectaSocApp extends StatefulWidget {
  const ConectaSocApp({super.key});

  @override
  State<ConectaSocApp> createState() => _ConectaSocAppState();
}

class _ConectaSocAppState extends State<ConectaSocApp> {
  late final AppRouter _appRouter;
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authBloc: sl<AuthBloc>());

    // Solicitar permisos al iniciar (opcionalmente se puede mover a otro lugar)
    sl<NotificationService>().requestPermissions();

    // Escuchar clics en notificaciones para navegación
    _notificationSubscription =
        sl<NotificationService>().onNotificationClick.listen((articleId) {
      if (articleId != null) {
        // Navegar al detalle del artículo usando el router
        _appRouter.router.pushNamed(
          RouteNames.articleDetail,
          pathParameters: {'articleId': articleId},
        );
      }
    });

    // Iniciar verificación de autenticación
    sl<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Determinar el locale actual basado en el estado de autenticación.
          Locale? userLocale;
          if (state is AuthAuthenticated) {
            userLocale = Locale(state.user.language);
          } else if (state is AuthLocalUser) {
            userLocale = Locale(state.localUser.language);
          } else if (state is AuthUnauthenticated && state.language != null) {
            userLocale = Locale(state.language!);
          }

          return MaterialApp.router(
            // Clave para que el SnackBarService funcione globalmente.
            scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (kIsWeb && child != null) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Globals.maxWebWidth,
                    ),
                    child: child,
                  ),
                );
              }
              return child!;
            },

            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: userLocale, // Aquí se establece el idioma dinámicamente
            localeListResolutionCallback: (deviceLocales, supportedLocales) {
              // 1. Prioridad: idioma guardado del usuario
              if (userLocale != null) {
                return userLocale;
              }
              // 2. Segunda opción: idioma del dispositivo
              if (deviceLocales != null) {
                for (var deviceLocale in deviceLocales) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode ==
                        deviceLocale.languageCode) {
                      // Encontramos una coincidencia, la devolvemos.
                      return supportedLocale;
                    }
                  }
                }
              }
              // 3. Fallback: primer idioma soportado (ej. español)
              return supportedLocales.first;
            },

            // THEME
            theme: AppTheme.light,

            // Sistema de navegación con GoRouter
            routerConfig: _appRouter.router,
            scrollBehavior: AppScrollBehavior(),
          );
        },
      ),
    );
  }
}
