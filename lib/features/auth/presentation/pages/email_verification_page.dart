// lib/features/auth/presentation/pages/email_verification_page.dart

import 'package:conectasoc/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _emailSent = false;
  bool _isSendingInitial = true;

  @override
  void initState() {
    super.initState();
    // Enviar email de verificación automáticamente al cargar la página
    _sendInitialVerificationEmail();
  }

  Future<void> _sendInitialVerificationEmail() async {
    // Esperar un poco para que el usuario se cree completamente
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified && mounted) {
        await user.sendEmailVerification();
        if (mounted) {
          setState(() {
            _isSendingInitial = false;
          });
        }
      }
    } catch (e) {
      // Si falla, el usuario puede reenviarlo manualmente
      debugPrint('Error al enviar email inicial: $e');
      if (mounted) {
        setState(() {
          _isSendingInitial = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _emailSent = false;
    });

    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar email: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _checkVerification() async {
    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = firebase.FirebaseAuth.instance.currentUser;

        if (refreshedUser?.emailVerified ?? false) {
          // Email verificado, recargar el estado del auth
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckRequested());
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El email aún no ha sido verificado'),
                backgroundColor: AppTheme.warning,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifica tu Email'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Icon(
                Icons.mark_email_unread_outlined,
                size: AppTheme.iconSizeLarge,
                color: AppTheme.primary,
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // Título
              Text(
                '¡Verifica tu Email!',
                style: AppTheme.articleTitle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceSm),

              // Mensaje
              Text(
                _isSendingInitial
                    ? 'Enviando email de verificación...'
                    : 'Hemos enviado un email de verificación a:',
                style: AppTheme.articleBody(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceXs),

              // Email
              Text(
                widget.email,
                style: AppTheme.verificationEmail(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Instrucciones
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: AppTheme.borderRadiusDefault,
                  border: Border.all(color: AppTheme.infoBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: AppTheme.infoBannerTitle,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    _buildInstruction('1. Revisa tu bandeja de entrada'),
                    _buildInstruction(
                        '2. Haz clic en el enlace de verificación'),
                    _buildInstruction(
                        '3. Vuelve aquí y presiona "Ya verifiqué"'),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // Indicador mientras se envía el email inicial
              if (_isSendingInitial)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppTheme.spaceSm),
                    Text('Enviando email...'),
                    SizedBox(height: AppTheme.spaceLg),
                  ],
                ),

              // Botón verificar
              ElevatedButton.icon(
                onPressed: _checkVerification,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Ya verifiqué mi email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLg,
                    vertical: AppTheme.spaceSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadiusDefault,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),

              // Botón reenviar
              if (_emailSent)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceXs),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: AppTheme.borderRadiusDefault,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successIcon),
                      const SizedBox(width: AppTheme.spaceXs),
                      const Text('¡Email reenviado!'),
                    ],
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? const SizedBox(
                          width: AppTheme.iconSizeSmall,
                          height: AppTheme.iconSizeSmall,
                          child: CircularProgressIndicator(
                              strokeWidth: AppTheme.loadingStrokeWidth),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isResending
                      ? 'Reenviando...'
                      : '¿No recibiste el email? Reenviar'),
                ),
              const SizedBox(height: AppTheme.spaceLg),

              // Botón volver al login
              OutlinedButton(
                onPressed: () {
                  // Cerrar sesión y volver al login
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLg,
                    vertical: AppTheme.spaceSm,
                  ),
                ),
                child: const Text('Volver al Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXxs),
      child: Row(
        children: [
          Icon(Icons.arrow_right,
              size: AppTheme.iconSizeSmall + 4, color: AppTheme.infoIcon),
          const SizedBox(width: AppTheme.spaceXs),
          Expanded(
            child: Text(
              text,
              style: AppTheme.verificationInstruction,
            ),
          ),
        ],
      ),
    );
  }
}
