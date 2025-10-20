// lib/features/auth/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Image.asset(
                  'assets/images/logo_conectasoc_t.png',
                  fit: BoxFit.contain,
                  // color: Colors.blue, // ⚠️ Opcional: ver nota abajo
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ConectAsoc',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Portal de Asociaciones',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
