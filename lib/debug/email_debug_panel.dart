// lib/debug/email_debug_panel.dart
// ⚠️ SOLO PARA DESARROLLO - Eliminar en producción

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class EmailDebugPanel extends StatefulWidget {
  const EmailDebugPanel({super.key});

  @override
  State<EmailDebugPanel> createState() => _EmailDebugPanelState();
}

class _EmailDebugPanelState extends State<EmailDebugPanel> {
  final List<String> _logs = [];
  bool _isExpanded = false;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _authInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _setupAuthListener();
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  void _setupAuthListener() {
    firebase.FirebaseAuth.instance.authStateChanges().listen((user) {
      _addLog('🔄 Auth state cambió: ${user?.email ?? "null"}');
      _loadUserInfo();
    });
  }

  Future<void> _loadUserInfo() async {
    final user = firebase.FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _userInfo = {'error': 'No hay usuario autenticado'};
        _authInfo = null;
      });
      return;
    }

    try {
      await user.reload();
      final refreshedUser = firebase.FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        _userInfo = {
          'uid': refreshedUser?.uid,
          'email': refreshedUser?.email,
          'emailVerified': refreshedUser?.emailVerified,
          'displayName': refreshedUser?.displayName,
          'photoURL': refreshedUser?.photoURL,
          'phoneNumber': refreshedUser?.phoneNumber,
          'creationTime': refreshedUser?.metadata.creationTime?.toString(),
          'lastSignInTime': refreshedUser?.metadata.lastSignInTime?.toString(),
          'providers':
              refreshedUser?.providerData.map((p) => p.providerId).toList(),
        };

        _authInfo = {
          'currentUser': firebase.FirebaseAuth.instance.currentUser != null,
          'app': firebase.FirebaseAuth.instance.app.name,
          'languageCode': firebase.FirebaseAuth.instance.languageCode,
        };
      });
    } catch (e) {
      _addLog('❌ Error al cargar info: $e');
    }
  }

  Future<void> _sendTestEmail() async {
    _addLog('📧 Iniciando envío de email...');

    try {
      final user = firebase.FirebaseAuth.instance.currentUser;

      if (user == null) {
        _addLog('❌ No hay usuario autenticado');
        return;
      }

      _addLog('👤 Usuario: ${user.email}');
      _addLog('🆔 UID: ${user.uid}');
      _addLog('✅ Verificado: ${user.emailVerified}');

      if (user.emailVerified) {
        _addLog('⚠️ El email ya está verificado');
        return;
      }

      await user.sendEmailVerification();
      _addLog('✅ sendEmailVerification() ejecutado sin errores');
      _addLog('📬 Email debería llegar en 1-5 minutos');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email enviado. Revisa logs para detalles.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on firebase.FirebaseAuthException catch (e) {
      _addLog('❌ FirebaseAuthException: ${e.code}');
      _addLog('📝 Mensaje: ${e.message}');
      _addLog('📍 Stack: ${e.stackTrace}');
    } catch (e, stackTrace) {
      _addLog('❌ Error general: $e');
      _addLog('📍 Stack: $stackTrace');
    }
  }

  Future<void> _checkVerification() async {
    _addLog('🔍 Verificando estado del email...');

    try {
      final user = firebase.FirebaseAuth.instance.currentUser;

      if (user == null) {
        _addLog('❌ No hay usuario autenticado');
        return;
      }

      _addLog('🔄 Recargando usuario...');
      await user.reload();

      final refreshedUser = firebase.FirebaseAuth.instance.currentUser;
      if (!mounted) return;

      final isVerified = refreshedUser?.emailVerified ?? false;

      _addLog(isVerified ? '✅ EMAIL VERIFICADO!' : '❌ Email aún no verificado');

      _loadUserInfo();
    } catch (e) {
      _addLog('❌ Error al verificar: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  void _copyLogs() {
    final allLogs = _logs.reversed.join('\n');
    Clipboard.setData(ClipboardData(text: allLogs));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copiados al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber,
              child: Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    'DEBUG: Email Verification',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            // User Info
            if (_userInfo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 USER INFO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._userInfo!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        )),
                  ],
                ),
              ),

            // Auth Info
            if (_authInfo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.purple.shade900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔐 AUTH INFO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._authInfo!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        )),
                  ],
                ),
              ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _sendTestEmail,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Enviar Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _checkVerification,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Check Verificación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loadUserInfo,
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Reload Info'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _copyLogs,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar Logs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _clearLogs,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Logs
            Container(
              height: 300,
              color: Colors.black,
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay logs todavía...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color logColor = Colors.white;

                        if (log.contains('❌')) {
                          logColor = Colors.red.shade300;
                        } else if (log.contains('✅')) {
                          logColor = Colors.green.shade300;
                        } else if (log.contains('⚠️')) {
                          logColor = Colors.orange.shade300;
                        } else if (log.contains('📧') || log.contains('📬')) {
                          logColor = Colors.blue.shade300;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: logColor,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
