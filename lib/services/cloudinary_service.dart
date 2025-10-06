import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:conectasoc/services/snackbar_service.dart';

// Solo importar image si no es web
import 'package:image/image.dart' as img
    show decodeImage, copyResize, encodeJpg;

class CloudinaryService {
  /// Subir imagen a Cloudinary
  static Future<CloudinaryResponse> uploadImage({
    required File imageFile,
    CloudinaryImageType imageType = CloudinaryImageType.general,
    Map<String, String>? tags,
  }) async {
    try {
      // Validar archivo
      await _validateImageFile(imageFile);

      // Optimizar imagen (diferente para web vs móvil)
      final optimizedBytes = await _optimizeImage(imageFile);

      // Subir a Cloudinary
      final response = await _uploadToCloudinary(
        imageBytes: optimizedBytes,
        folder: imageType.folder,
        tags: tags,
      );

      return response;
    } catch (e) {
      return CloudinaryResponse.error('Error subiendo imagen: $e');
    }
  }

  /// Subir desde Uint8List (para web)
  static Future<CloudinaryResponse> uploadImageBytes({
    required Uint8List imageBytes,
    required String filename,
    CloudinaryImageType imageType = CloudinaryImageType.general,
    Map<String, String>? tags,
  }) async {
    try {
      // Validar tamaño
      if (imageBytes.length > CloudinaryConfig.maxFileSize) {
        throw Exception(
          'Archivo demasiado grande (${(imageBytes.length / (1024 * 1024)).toStringAsFixed(1)}MB). Máximo: ${CloudinaryConfig.maxFileSize ~/ (1024 * 1024)}MB',
        );
      }

      // Para web, enviar directamente sin optimización pesada
      final response = await _uploadToCloudinary(
        imageBytes: imageBytes,
        folder: imageType.folder,
        tags: tags,
        filename: filename,
      );

      return response;
    } catch (e) {
      return CloudinaryResponse.error('Error subiendo imagen: $e');
    }
  }

  /// Eliminar imagen de Cloudinary
  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature({
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      });

      final response = await http.post(
        Uri.parse(CloudinaryConfig.destroyUrl),
        body: {
          'public_id': publicId,
          'api_key': CloudinaryConfig.apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['result'] == 'ok';
      }

      return false;
    } catch (e) {
      SnackBarService.showSnackBar('Error eliminando imagen: $e', isError: true);
      return false;
    }
  }

  /// Generar URL con transformaciones
  static String getTransformedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? crop,
    int? quality,
  }) {
    final transforms = <String>[];

    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    if (crop != null) transforms.add('c_$crop');
    if (quality != null) transforms.add('q_$quality');

    if (transforms.isEmpty) return originalUrl;

    final transformString = transforms.join(',');
    return originalUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/$transformString/',
    );
  }

  // MÉTODOS PRIVADOS

  static Future<void> _validateImageFile(File file) async {
    if (!await file.exists()) {
      throw Exception('El archivo no existe');
    }

    final size = await file.length();
    if (size > CloudinaryConfig.maxFileSize) {
      throw Exception(
        'Archivo demasiado grande (${(size / (1024 * 1024)).toStringAsFixed(1)}MB). Máximo: ${CloudinaryConfig.maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    final extension = path.extension(file.path).toLowerCase().substring(1);
    if (!CloudinaryConfig.allowedFormats.contains(extension)) {
      throw Exception(
        'Formato no soportado ($extension). Formatos permitidos: ${CloudinaryConfig.allowedFormats.join(", ")}',
      );
    }
  }

  static Future<Uint8List> _optimizeImage(File imageFile) async {
    final originalBytes = await imageFile.readAsBytes();

    // En web, no podemos usar la librería image para optimización pesada
    // Enviamos directamente con transformaciones en Cloudinary
    if (kIsWeb) {
      SnackBarService.showSnackBar(
          'Web detected: Skipping client-side optimization, using Cloudinary transformations');
      return originalBytes;
    }

    // En móvil, optimizamos localmente
    try {
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es necesario
      var processedImage = originalImage;

      if (originalImage.width > CloudinaryConfig.maxImageWidth ||
          originalImage.height > CloudinaryConfig.maxImageHeight) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height
              ? CloudinaryConfig.maxImageWidth
              : null,
          height: originalImage.height > originalImage.width
              ? CloudinaryConfig.maxImageHeight
              : null,
        );
      }

      // Comprimir
      final compressedBytes = img.encodeJpg(
        processedImage,
        quality: CloudinaryConfig.normalQuality,
      );

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      SnackBarService.showSnackBar('Error in image optimization: $e', isError: true);
      // Si falla la optimización, enviar original
      return originalBytes;
    }
  }

  static Future<CloudinaryResponse> _uploadToCloudinary({
    required Uint8List imageBytes,
    required String folder,
    Map<String, String>? tags,
    String? filename,
  }) async {
    try {
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Parámetros básicos
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['folder'] = folder;

      // Para web, aplicar transformaciones en servidor para optimizar
      // if (kIsWeb) {
      //   request.fields['transformation'] = 'q_auto,f_auto,w_1200,h_800,c_limit';
      // }

      // Tags opcionales
      if (tags != null && tags.isNotEmpty) {
        final tagString =
            tags.entries.map((e) => '${e.key}:${e.value}').join(',');
        request.fields['tags'] = tagString;
      }

      // Contexto para tracking
      request.fields['context'] =
          'platform=${kIsWeb ? "web" : "mobile"}|app=conectasoc';

      // Adjuntar imagen
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename ?? '${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      // Enviar request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return CloudinaryResponse.success(responseData);
      } else {
        final errorData = json.decode(responseBody);
        final errorMessage =
            errorData['error']?['message'] ?? 'Error desconocido';
        return CloudinaryResponse.error('Error de Cloudinary: $errorMessage');
      }
    } catch (e) {
      return CloudinaryResponse.error('Error de conexión: $e');
    }
  }

  static String _generateSignature(Map<String, String> parameters) {
    // Ordenar parámetros
    final sortedParams = Map.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Crear string para firmar
    final paramString =
        sortedParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    final toSign = '$paramString${CloudinaryConfig.apiSecret}';

    // Generar SHA1
    final bytes = utf8.encode(toSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}