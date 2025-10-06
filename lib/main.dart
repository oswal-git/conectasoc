// lib/main.dart

import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

// Inyección de dependencias
import 'injection_container.dart';

// BLoC
import 'package:conectasoc/features/auth/presentation/presentation.dart';

// Router
import 'package:conectasoc/app/router/router.dart';
import 'package:conectasoc/services/snackbar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar dependencias (Clean Architecture)
  await init();

  runApp(const ConectaSocApp());
}

final _navigatorKey = GlobalKey<NavigatorState>();

class ConectaSocApp extends StatelessWidget {
  const ConectaSocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()
        ..add(AuthCheckRequested()), // Verificar estado de auth al iniciar
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final navigator = _navigatorKey.currentState;
          if (navigator == null) return;

          if (state is AuthError) {
            SnackBarService.showSnackBar(state.message, isError: true);
          } else if (state is AuthAuthenticated || state is AuthLocalUser) {
            navigator.pushNamedAndRemoveUntil(
                RouteNames.home, (route) => false);
          } else if (state is AuthUnauthenticated) {
            navigator.pushNamedAndRemoveUntil(
                RouteNames.welcome, (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            Locale? currentLocale;
            if (state is AuthAuthenticated) {
              currentLocale = Locale(state.user.language);
            }

            return MaterialApp(
              scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              navigatorKey: _navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale:
                  currentLocale, // Aquí se establece el idioma dinámicamente

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

              // Sistema de navegación con rutas nombradas
              initialRoute: RouteNames.splash,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
