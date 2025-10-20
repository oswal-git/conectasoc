import 'dart:async';

import 'package:conectasoc/features/auth/presentation/bloc/bloc.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia un temporizador para comprobar periódicamente si el email ha sido verificado.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        timer.cancel();
        // Si se verifica, se dispara el evento para re-evaluar el estado de autenticación.
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.verificationEmailSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorResendingEmail(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                l10n.verifyEmailHeadline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verifyEmailInstruction(widget.email),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _resendVerificationEmail,
                child: Text(l10n.resendEmail),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(AuthSignOutRequested()),
                child: Text(l10n.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
