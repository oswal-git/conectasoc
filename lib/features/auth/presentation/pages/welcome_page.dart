import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:conectasoc/app/router/route_names.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppTheme.infoIcon, AppTheme.infoBorder],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Iconos de la barra de estado en blanco sobre fondo azul
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme.infoIcon,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                  children: [
                    const SizedBox(
                        height: AppTheme.spaceTop), // Espacio superior

                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.onDarkPrimary,
                        borderRadius: AppTheme.borderRadiusLogoLg,
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
                        size: AppTheme.iconSizeMedium,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Título
                    Text(
                      l10n.appTitle,
                      style: AppTheme.welcomeTitle,
                    ),

                    const SizedBox(height: AppTheme.spaceXs),

                    Text(
                      l10n.welcomeSubtitle,
                      style: AppTheme.welcomeSubtitle,
                    ),

                    const SizedBox(
                        height: AppTheme
                            .spaceSection), // Espacio antes de las tarjetas

                    // Opciones de acceso
                    _ModeCard(
                      icon: Icons.visibility,
                      title: l10n.welcomeReadOnlyTitle,
                      description: l10n.welcomeReadOnlyDescription,
                      color: Colors.white,
                      onTap: () => _navigateToLocalSetup(context),
                    ),

                    const SizedBox(height: AppTheme.spaceSm),

                    _ModeCard(
                      icon: Icons.login,
                      title: l10n.welcomeLoginTitle,
                      description: l10n.welcomeLoginDescription,
                      color: Colors.white,
                      onTap: () => _navigateToLogin(context),
                    ),

                    const SizedBox(height: AppTheme.spaceSm),

                    _ModeCard(
                      icon: Icons.person_add,
                      title: l10n.createAccount,
                      description: l10n.welcomeRegisterDescription,
                      color: Colors.white,
                      onTap: () => _navigateToRegister(context),
                    ),

                    const SizedBox(height: AppTheme.spaceXl),
                  ],
                ),
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
      elevation: AppTheme.elevationCardHigh,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadiusCard,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceXs),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: AppTheme.borderRadiusDefault,
                ),
                child: Icon(
                  icon,
                  size: AppTheme.iconSizeCard,
                  color: AppTheme.infoIcon,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.cardTitle,
                    ),
                    const SizedBox(height: AppTheme.spaceXxs),
                    Text(
                      description,
                      style: AppTheme.cardDescription,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: AppTheme.iconSizeXs,
                color: AppTheme.neutralText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
