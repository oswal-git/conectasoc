// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:conectasoc/l10n/app_localizations.dart';

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
          final Locale? userLocale =
              (state is AuthAuthenticated) ? Locale(state.user.language) : null;

          return MaterialApp.router(
              // Clave para que el SnackBarService funcione globalmente.
              scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              debugShowCheckedModeBanner: false,
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
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                useMaterial3: true,

                // AppBar Theme
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),

                // Input Decoration Theme
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),

                // Elevated Button Theme
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Card Theme
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Sistema de navegación con GoRouter
              routerConfig: _appRouter.router);
        },
      ),
    );
  }
}
