import 'package:flutter/material.dart';
import 'package:conectasoc/app/router/route_names.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[700]!,
              Colors.blue[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Espacio superior

                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(51, 0, 0, 0),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people,
                      size: 64,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.welcomeSubtitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 60), // Espacio antes de las tarjetas

                  // Opciones de acceso
                  _ModeCard(
                    icon: Icons.visibility,
                    title: l10n.welcomeReadOnlyTitle,
                    description: l10n.welcomeReadOnlyDescription,
                    color: Colors.white,
                    onTap: () => _navigateToLocalSetup(context),
                  ),

                  const SizedBox(height: 16),

                  _ModeCard(
                    icon: Icons.login,
                    title: l10n.welcomeLoginTitle,
                    description: l10n.welcomeLoginDescription,
                    color: Colors.white,
                    onTap: () => _navigateToLogin(context),
                  ),

                  const SizedBox(height: 16),

                  _ModeCard(
                    icon: Icons.person_add,
                    title: l10n.createAccount,
                    description: l10n.welcomeRegisterDescription,
                    color: Colors.white,
                    onTap: () => _navigateToRegister(context),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLocalSetup(BuildContext context) {
    GoRouter.of(context).push(RouteNames.localUserSetup);
  }

  void _navigateToLogin(BuildContext context) {
    GoRouter.of(context).push(RouteNames.login);
  }

  void _navigateToRegister(BuildContext context) {
    GoRouter.of(context).push(RouteNames.register);
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
