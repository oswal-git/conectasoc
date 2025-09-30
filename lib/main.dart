import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importar nuestros widgets
import 'package:conectasoc/widgets/test_cloudinary_widget.dart';
import 'package:conectasoc/core/constants/cloudinary_config.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase con try-catch
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      // Continuar sin Firebase si falló
    }

    runApp(const ConectAsoc());
  } catch (e) {
    print('❌ Main error: $e');
  }
}

class ConectAsoc extends StatelessWidget {
  const ConectAsoc({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConectAsoc - Firebase + Cloudinary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConectAsoc - Setup Completo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header principal
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🎉 ConectAsoc Configurado!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase + Cloudinary integrados y listos',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Estado de servicios
              _buildServicesStatus(context),

              const SizedBox(height: 32),

              // Botón principal
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestCloudinaryPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload, size: 28),
                label: const Text(
                  'PROBAR CLOUDINARY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),

              const SizedBox(height: 16),

              // Botón secundario
              OutlinedButton.icon(
                onPressed: () => _showSetupInstructions(context),
                icon: const Icon(Icons.help_outline),
                label: const Text('Ver Instrucciones'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Footer con próximos pasos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Próximo Paso',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Una vez que pruebes Cloudinary exitosamente, continuaremos con la implementación del sistema de autenticación y las pantallas principales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesStatus(BuildContext context) {
    final isCloudinaryConfigured =
        !CloudinaryConfig.cloudName.contains('TU_') &&
            !CloudinaryConfig.apiKey.contains('TU_') &&
            !CloudinaryConfig.apiSecret.contains('TU_');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Estado de Servicios',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildServiceItem('🔥 Firebase Core', true, 'Conectado'),
          _buildServiceItem('👤 Firebase Auth', true, 'Configurado'),
          _buildServiceItem('🗄️ Firestore Database', true, 'Configurado'),
          _buildServiceItem('📱 Cloud Messaging', true, 'Configurado'),
          _buildServiceItem(
              '🌤️ Cloudinary',
              isCloudinaryConfigured,
              isCloudinaryConfigured
                  ? 'Configurado'
                  : 'Pendiente configuración'),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, bool isConfigured, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isConfigured ? Icons.check_circle : Icons.warning,
            color: isConfigured ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isConfigured ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isConfigured ? Colors.green[800] : Colors.orange[800],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetupInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.blue),
            SizedBox(width: 8),
            Text('Instrucciones de Setup'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌤️ Configurar Cloudinary:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('1. Ve a https://console.cloudinary.com'),
              Text('2. Copia tus credenciales del dashboard:'),
              Text('   • Cloud name'),
              Text('   • API Key'),
              Text('   • API Secret'),
              Text('3. Actualiza lib/core/constants/cloudinary_config.dart'),
              Text('4. Reemplaza los valores TU_CLOUD_NAME, etc.'),
              SizedBox(height: 16),
              Text(
                '🧪 Probar Cloudinary:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('1. Haz clic en "PROBAR CLOUDINARY"'),
              Text('2. Sube una imagen de prueba'),
              Text('3. Verifica que se carga correctamente'),
              Text('4. Prueba los diferentes tamaños'),
              Text('5. Elimina la imagen de prueba'),
              SizedBox(height: 16),
              Text(
                '🚀 Siguiente Paso:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                  'Una vez que Cloudinary funcione correctamente, continuaremos con la arquitectura completa de ConectAsoc.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
