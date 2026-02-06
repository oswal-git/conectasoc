// lib/features/auth/presentation/pages/email_verification_page.dart

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
            backgroundColor: Colors.red,
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
                backgroundColor: Colors.orange,
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
            backgroundColor: Colors.red,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                '¡Verifica tu Email!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mensaje
              Text(
                _isSendingInitial
                    ? 'Enviando email de verificación...'
                    : 'Hemos enviado un email de verificación a:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                widget.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Instrucciones
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstruction('1. Revisa tu bandeja de entrada'),
                    _buildInstruction(
                        '2. Haz clic en el enlace de verificación'),
                    _buildInstruction(
                        '3. Vuelve aquí y presiona "Ya verifiqué"'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Indicador mientras se envía el email inicial
              if (_isSendingInitial)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Enviando email...'),
                    SizedBox(height: 32),
                  ],
                ),

              // Botón verificar
              ElevatedButton.icon(
                onPressed: _checkVerification,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Ya verifiqué mi email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón reenviar
              if (_emailSent)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('¡Email reenviado!'),
                    ],
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isResending
                      ? 'Reenviando...'
                      : '¿No recibiste el email? Reenviar'),
                ),
              const SizedBox(height: 32),

              // Botón volver al login
              OutlinedButton(
                onPressed: () {
                  // Cerrar sesión y volver al login
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_right, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
