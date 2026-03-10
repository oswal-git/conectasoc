// lib/features/auth/presentation/pages/splash_page.dart

import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.onDarkPrimary,
                borderRadius: AppTheme.borderRadiusLogo,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Image.asset(
                  'assets/images/logo_conectasoc_t.png',
                  fit: BoxFit.contain,
                  // color: Colors.blue, // ⚠️ Opcional: ver nota abajo
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            const Text(
              'ConectAsoc',
              style: AppTheme.splashTitle,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            const Text(
              'Portal de Asociaciones',
              style: AppTheme.splashSubtitle,
            ),
            const SizedBox(height: AppTheme.spaceXl),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onDarkPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder temporal para HomePage
// NOTA: El widget HomePage parece tener errores de sintaxis/fusión en el archivo original.
// Deberías moverlo a su propio archivo (p. ej., 'home_page.dart') y corregirlo.
// Por ahora, lo he eliminado para simplificar la corrección del problema principal.
// Necesitarás una implementación válida de HomePage y WelcomePage para que la navegación funcione.
