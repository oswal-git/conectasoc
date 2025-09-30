import 'dart:io';
import 'package:conectasoc/services/cloudinary_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:conectasoc/core/constants/cloudinary_config.dart';

class TestCloudinaryPage extends StatefulWidget {
  const TestCloudinaryPage({super.key});

  @override
  State<TestCloudinaryPage> createState() => _TestCloudinaryPageState();
}

class _TestCloudinaryPageState extends State<TestCloudinaryPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadedImageUrl;
  String? _publicId;
  String _status = 'Listo para subir imagen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Cloudinary ${kIsWeb ? "(Web)" : "(Móvil)"}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de plataforma
              _buildPlatformInfo(),

              const SizedBox(height: 16),

              // Configuración actual
              _buildConfigCard(),

              const SizedBox(height: 20),

              // Estado actual
              _buildStatusCard(),

              const SizedBox(height: 20),

              // Botones de acción
              _buildActionButtons(),

              const SizedBox(height: 20),

              // Indicador de carga o imagen
              _isUploading ? _buildLoadingWidget() : _buildImageWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kIsWeb ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kIsWeb ? Colors.blue[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            kIsWeb ? Icons.web : Icons.phone_android,
            color: kIsWeb ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kIsWeb
                  ? '🌐 Ejecutándose en Web - Optimización en servidor'
                  : '📱 Ejecutándose en Móvil - Optimización local',
              style: TextStyle(
                color: kIsWeb ? Colors.blue[800] : Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ Configuración Cloudinary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildConfigRow('Cloud Name', CloudinaryConfig.cloudName),
            _buildConfigRow('Upload Preset', CloudinaryConfig.uploadPreset),
            _buildConfigRow(
                'API Key',
                CloudinaryConfig.apiKey.length > 10
                    ? '${CloudinaryConfig.apiKey.substring(0, 6)}...'
                    : '❌ NO CONFIGURADO'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    final isConfigured = !value.contains('TU_') && !value.contains('❌');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isConfigured ? Colors.green : Colors.red,
                fontWeight: isConfigured ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
          Icon(
            isConfigured ? Icons.check_circle : Icons.error,
            color: isConfigured ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(_status),
          if (_publicId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Public ID: $_publicId',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isConfigured = !CloudinaryConfig.cloudName.contains('TU_') &&
        !CloudinaryConfig.apiKey.contains('TU_');

    if (!isConfigured) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: const Column(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            SizedBox(height: 8),
            Text(
              '⚠️ Configuración Requerida',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Debes configurar las credenciales de Cloudinary en cloudinary_config.dart',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading
              ? null
              : () => _pickAndUploadImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: Text(kIsWeb ? 'Seleccionar Archivo' : 'Subir desde Galería'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),

        // Solo mostrar cámara en móvil
        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading
                ? null
                : () => _pickAndUploadImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tomar Foto'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],

        if (_publicId != null) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _deleteImage,
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Imagen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 16),
          const Text(
            'Procesando imagen...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            kIsWeb
                ? 'Subiendo y optimizando en Cloudinary'
                : 'Optimizando localmente y subiendo',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_uploadedImageUrl == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay imagen subida',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selecciona una imagen para subir',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✅ Imagen Subida Exitosamente:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
        const SizedBox(height: 12),

        // Imagen
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _uploadedImageUrl!,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Error cargando imagen'),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botones de diferentes tamaños
        _buildImageSizeButtons(),
      ],
    );
  }

  Widget _buildImageSizeButtons() {
    if (_uploadedImageUrl == null) return const SizedBox.shrink();

    final urls = CloudinaryConfig.getImageUrls(_uploadedImageUrl!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ver diferentes tamaños:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: urls.entries.map((entry) {
            return ElevatedButton(
              onPressed: () => _showImagePreview(entry.value, entry.key),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(entry.key.toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }

  // MÉTODOS DE FUNCIONALIDAD

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth:
            kIsWeb ? null : 1200, // En web dejamos que Cloudinary optimice
        maxHeight: kIsWeb ? null : 800,
        imageQuality: kIsWeb ? null : 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
        _status = 'Preparando imagen...';
      });

      setState(() {
        _status = kIsWeb
            ? 'Subiendo y optimizando en servidor...'
            : 'Optimizando localmente...';
      });

      CloudinaryResponse response;

      if (kIsWeb) {
        // En web, usar bytes directamente
        final imageBytes = await image.readAsBytes();
        response = await CloudinaryService.uploadImageBytes(
          imageBytes: imageBytes,
          filename: image.name,
          imageType: CloudinaryImageType.general,
          tags: {
            'test': 'true',
            'platform': 'web',
            'app': 'conectasoc',
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // En móvil, usar File
        final imageFile = File(image.path);
        response = await CloudinaryService.uploadImage(
          imageFile: imageFile,
          imageType: CloudinaryImageType.general,
          tags: {
            'test': 'true',
            'platform': 'mobile',
            'app': 'conectasoc',
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        );
      }

      setState(() {
        _isUploading = false;
      });

      if (response.success) {
        setState(() {
          _uploadedImageUrl = response.secureUrl;
          _publicId = response.publicId;
          _status = '✅ ¡Imagen subida exitosamente!';
        });

        _showSuccessSnackBar('✅ Imagen subida: ${response.publicId}');
      } else {
        setState(() {
          _status = '❌ Error: ${response.error}';
        });

        _showErrorSnackBar('❌ Error: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _status = '❌ Error inesperado: $e';
      });

      _showErrorSnackBar('❌ Error: $e');
    }
  }

  Future<void> _deleteImage() async {
    if (_publicId == null) return;

    try {
      setState(() {
        _isUploading = true;
        _status = 'Eliminando imagen...';
      });

      final success = await CloudinaryService.deleteImage(_publicId!);

      setState(() {
        _isUploading = false;
      });

      if (success) {
        setState(() {
          _uploadedImageUrl = null;
          _publicId = null;
          _status = '✅ Imagen eliminada exitosamente';
        });

        _showSuccessSnackBar('✅ Imagen eliminada');
      } else {
        setState(() {
          _status = '❌ Error eliminando imagen';
        });

        _showErrorSnackBar('❌ Error eliminando imagen');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _status = '❌ Error: $e';
      });
    }
  }

  void _showImagePreview(String imageUrl, String size) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Vista: ${size.toUpperCase()}'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Icon(Icons.error, size: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URL:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    imageUrl,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
