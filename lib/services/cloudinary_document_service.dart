// Extensión del CloudinaryService existente para manejar documentos

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:conectasoc/core/constants/cloudinary_config.dart';
import 'package:crypto/crypto.dart';

/// Respuesta específica para subida de documentos
class CloudinaryDocumentResponse {
  final bool success;
  final String? urlDoc;
  final String? urlThumb;
  final String? publicId;
  final String? error;

  CloudinaryDocumentResponse({
    required this.success,
    this.urlDoc,
    this.urlThumb,
    this.publicId,
    this.error,
  });

  factory CloudinaryDocumentResponse.success({
    required String urlDoc,
    required String urlThumb,
    required String publicId,
  }) {
    return CloudinaryDocumentResponse(
      success: true,
      urlDoc: urlDoc,
      urlThumb: urlThumb,
      publicId: publicId,
    );
  }

  factory CloudinaryDocumentResponse.error(
    String error,
  ) {
    return CloudinaryDocumentResponse(
      success: false,
      error: error,
    );
  }

  //
}

class CloudinaryDocumentService {
  /// Subir documento a Cloudinary
  /// Soporta PDF, DOCX, XLSX, PPTX
  static Future<CloudinaryDocumentResponse> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String associationId,
    required String categoryId,
    required String subcategoryId,
  }) async {
    try {
      // Validar tamaño (máximo 25MB para documentos)
      const maxDocumentSize = 25 * 1024 * 1024; // 25MB
      if (fileBytes.length > maxDocumentSize) {
        throw Exception(
          'Documento demasiado grande (${(fileBytes.length / (1024 * 1024)).toStringAsFixed(1)}MB). Máximo: 25MB',
        );
      }

      final extension = filename.split('.').last.toLowerCase();
      // Construir la ruta del folder
      final folder = '$associationId/$categoryId/$subcategoryId';

      // PDFs se suben como resource_type=image para poder generar thumbnails
      // con transformaciones (pg_1). El resto de documentos van como raw.
      final isPdf = extension == 'pdf';

      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ extension: $extension');

      // Seleccionar preset según tipo de documento
      final preset = _presetForExtension(extension);
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ preset: $preset');
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ folder: $folder');

      final CloudinaryDocumentResponse documentResponse;
      if (isPdf) {
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ _uploadToCloudinaryImage');
        documentResponse = await _uploadToCloudinaryImage(
          fileBytes: fileBytes,
          filename: filename,
          folder: folder,
          preset: preset,
        );
      } else {
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ _uploadToCloudinaryRaw');
        documentResponse = await _uploadToCloudinaryRaw(
          fileBytes: fileBytes,
          filename: filename,
          folder: folder,
          preset: preset,
        );
      }

      if (!documentResponse.success) {
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ ${documentResponse.error ?? 'Error al subir documento'}');
        return CloudinaryDocumentResponse.error(
            documentResponse.error ?? 'Error al subir documento');
      }

      // Thumbnail:
      // - PDF y Office → construir URL dinámica y persistirla en Cloudinary
      // - Otros        → placeholder estático
      final isOffice = _isOfficeDocument(extension);
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ isOffice: $isOffice');
      String thumbUrl;
      if ((isPdf || isOffice) && documentResponse.publicId != null) {
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ _buildPdfThumbnailUrl');
        thumbUrl = await _persistThumbnail(
          publicId: documentResponse.publicId!,
          originalExtension: extension,
          folder: folder,
        );
      } else {
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ _getDefaultThumbnail');
        thumbUrl = _getDefaultThumbnail(filename);
        debugPrint(
            '🧪 CloudinaryDocumentService: uploadDocument ✅ thumbUrl: $thumbUrl');
      }

      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ documentResponse.urlDoc!: ${documentResponse.urlDoc!}');
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ thumbUrl: $thumbUrl');
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ✅ documentResponse.publicId!: ${documentResponse.publicId!}');

      return CloudinaryDocumentResponse.success(
        urlDoc: documentResponse.urlDoc!,
        urlThumb: thumbUrl,
        publicId: documentResponse.publicId!,
      );
    } catch (e) {
      debugPrint(
          '🧪 CloudinaryDocumentService: uploadDocument ❌ Error subiendo documento: $e');
      return CloudinaryDocumentResponse.error('Error subiendo documento: $e');
    }
  }

  /// Subir archivo raw a Cloudinary
  static Future<CloudinaryDocumentResponse> _uploadToCloudinaryRaw({
    required Uint8List fileBytes,
    required String filename,
    required String folder,
    required String preset,
  }) async {
    try {
      // El endpoint raw es distinto al de imágenes
      final rawUploadUrl = CloudinaryConfig.uploadUrlDoc;
      debugPrint(
          '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ rawUploadUrl: $rawUploadUrl');

      final uri = Uri.parse(rawUploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Parámetros básicos
      request.fields['upload_preset'] = preset;
      request.fields['asset_folder'] = folder;
      debugPrint(
          '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ preset: $preset');
      debugPrint(
          '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ folder: $folder');

      // Tags para organización
      request.fields['tags'] = 'document,app:conectasoc';
      debugPrint(
          '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ tags: document,app:conectasoc');

      // Aspose: convierte automáticamente docs Office a PDF en Cloudinary,
      // lo que permite aplicar transformaciones de imagen (pg_1) para thumbnails.
      // request.fields['resource_type'] = 'raw';
      // request.fields['raw_convert'] = 'aspose';
      // request.fields['eager'] = 'w_300,h_400,c_fit,f_jpg,pg_1';

      // Adjuntar archivo
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      // Enviar request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        // El preset ya tiene configurado raw_convert: aspose en Cloudinary.
        // El thumbnail se construirá y persistirá en un paso posterior.
        return CloudinaryDocumentResponse.success(
          urlDoc: responseData['secure_url'] ?? responseData['url'],
          urlThumb: '',
          publicId: responseData['public_id'],
        );
      } else {
        final errorData = json.decode(responseBody);
        final errorMessage =
            errorData['error']?['message'] ?? 'Error desconocido';
        debugPrint(
            '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ Error de Cloudinary: $errorMessage');
        return CloudinaryDocumentResponse.error(
            'Error de Cloudinary: $errorMessage');
      }
    } catch (e) {
      debugPrint(
          '🧪 CloudinaryDocumentService: _uploadToCloudinaryRaw ✅ Error de conexión: $e');
      return CloudinaryDocumentResponse.error('Error de conexión: $e');
    }
  }

  // Subir PDF a Cloudinary como image para poder aplicar transformaciones
  /// y generar thumbnails con pg_1.
  static Future<CloudinaryDocumentResponse> _uploadToCloudinaryImage({
    required Uint8List fileBytes,
    required String filename,
    required String folder,
    required String preset,
  }) async {
    try {
      final uri = Uri.parse(CloudinaryConfig.uploadUrlImage);
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = preset;
      request.fields['asset_folder'] = folder;
      request.fields['tags'] = 'document,app:conectasoc';

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final publicId = responseData['public_id'] as String;
        // Usar la secure_url exacta que devuelve Cloudinary (incluye versión)
        final secureUrl = responseData['secure_url'] as String? ?? '';
        return CloudinaryDocumentResponse.success(
          urlDoc: secureUrl,
          urlThumb: '',
          publicId: publicId,
        );
      } else {
        final errorData = json.decode(responseBody);
        final errorMessage =
            errorData['error']?['message'] ?? 'Error desconocido';
        return CloudinaryDocumentResponse.error(
            'Error de Cloudinary: $errorMessage');
      }
    } catch (e) {
      return CloudinaryDocumentResponse.error('Error de conexión: $e');
    }
  }

  /// Persiste el thumbnail de un documento (PDF o Office) en Cloudinary.
  ///
  /// Cloudinary soporta subida por URL usando application/x-www-form-urlencoded
  /// con `file` = URL. MultipartRequest no funciona para este caso.
  ///
  /// Flujo:
  ///   1. Construye la URL dinámica de la primera página
  // ignore: unintended_html_in_doc_comment
  ///   2. POST urlencoded a /image/upload con file=<url>
  ///   3. Para Office: elimina el PDF intermedio (resource_type=image)
  ///   4. Devuelve la secure_url del thumbnail persistente
  static Future<String> _persistThumbnail({
    required String publicId,
    required String originalExtension,
    required String folder,
  }) async {
    final cloudName = CloudinaryConfig.cloudName;
    final isPdf = originalExtension == 'pdf';

    // El publicId de Cloudinary incluye la extensión del archivo original
    // (ej: "Borrador_eopz4q.doc"). Para construir la URL del PDF generado
    // por Aspose hay que quitarla, porque Aspose añade .{ext}.pdf al publicId base.
    // Ejemplo: publicId="name.doc" → Aspose genera "name.doc.pdf"
    //          pero si ya incluye la ext, quedaria "name.doc.doc.pdf" ❌
    // Solución: usar el publicId tal cual — Cloudinary/Aspose genera {publicId}.pdf
    // sin duplicar la extensión.
    //
    // URL dinámica de la primera página:
    // PDF:    image/upload/c_limit,w_2000,f_jpg,pg_1/{publicId}.pdf
    //         (el PDF subido como image ya tiene .pdf, no hace falta añadir)
    // Office: image/upload/c_limit,w_2000,f_jpg,pg_1/{publicId}.pdf
    //         (Aspose crea el PDF con el mismo publicId + .pdf al final)
    final dynamicThumbUrl =
        'https://res.cloudinary.com/$cloudName/image/upload/'
        'c_limit,w_2000,f_jpg,pg_1/$publicId.pdf';

    debugPrint(
        '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ publicId: $publicId');
    debugPrint(
        '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ dynamicThumbUrl: $dynamicThumbUrl');

    // Aspose convierte de forma asíncrona aunque eager_async=false en el preset.
    // Esperamos hasta que el PDF esté disponible (máx. ~10s).
    final thumbReady = await _waitForThumbnail(dynamicThumbUrl);
    if (!thumbReady) {
      debugPrint(
          '🖼️ CloudinaryDocumentService: _persistThumbnail → PDF aún no disponible, usando dynamicThumbUrl como fallback');
      return dynamicThumbUrl;
    }

    try {
      // Persistir la URL dinámica como asset independiente.
      // POST urlencoded con file=<url> — Cloudinary descarga y almacena.
      // public_id omitido: presets unsigned no lo permiten.
      final response = await http.post(
        Uri.parse(CloudinaryConfig.uploadUrlImage),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'file': dynamicThumbUrl,
          'upload_preset': CloudinaryConfig.uploadPresetImagen,
          'asset_folder': folder,
          'tags': 'thumb,app:conectasoc',
        },
      );

      debugPrint(
          '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ status: ${response.statusCode}');
      debugPrint(
          '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ body: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint(
            '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ FAILED, usando dynamicThumbUrl');
        // Si falla la persistencia, devolver la URL dinámica como fallback
        return dynamicThumbUrl; // fallback
      }

      final responseData = json.decode(response.body);
      final persistentThumbUrl =
          responseData['secure_url'] as String? ?? dynamicThumbUrl;

      debugPrint(
          '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ persistentThumbUrl: $persistentThumbUrl');

      // Para Office: eliminar el PDF intermedio generado por Aspose.
      // Para PDF: el recurso image ES el documento, no se elimina.
      if (!isPdf) {
        await _deleteCloudinaryResource(
          publicId: publicId,
          resourceType: 'image',
        );
      }
      return persistentThumbUrl;
    } catch (e) {
      debugPrint(
          '🖼️ CloudinaryDocumentService: _persistThumbnail ➡️ EXCEPTION: $e');
      return dynamicThumbUrl; // fallback: URL dinámica (CDN la cachea)
    }
  }

  /// Espera hasta que la URL dinámica del thumbnail esté disponible en Cloudinary.
  /// Hace HEAD requests con backoff hasta [maxAttempts] intentos.
  /// Devuelve true si está disponible, false si se agotó el tiempo.
  static Future<bool> _waitForThumbnail(
    String url, {
    int maxAttempts = 6,
    Duration initialDelay = const Duration(seconds: 2),
  }) async {
    var delay = initialDelay;
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      try {
        final response = await http.head(Uri.parse(url));
        debugPrint(
            '🖼️ _waitForThumbnail attempt ${i + 1}/$maxAttempts → ${response.statusCode}');
        if (response.statusCode == 200) return true;
      } catch (_) {}
      // Backoff exponencial: 2s, 3s, 4.5s, 6.7s, 10s
      delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
    }
    return false;
  }

  /// Elimina un recurso de Cloudinary mediante firma autenticada.
  static Future<void> _deleteCloudinaryResource({
    required String publicId,
    required String resourceType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature({
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      });
      final destroyUrl =
          'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/$resourceType/destroy';
      final response = await http.post(
        Uri.parse(destroyUrl),
        body: {
          'public_id': publicId,
          'api_key': CloudinaryConfig.apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      final result = json.decode(response.body);
      debugPrint(
          '🗑️ CloudinaryDocumentService: _deleteCloudinaryResource ➡️ publicId: $publicId '
          'resourceType: $resourceType '
          'status: ${response.statusCode} '
          'result: ${result["result"]} '
          'error: ${result["error"]}');
    } catch (e) {
      debugPrint(
          '🗑️ CloudinaryDocumentService: _deleteCloudinaryResource ➡️ EXCEPTION: $e');
    }
  }

  /// Devuelve el preset de Cloudinary adecuado para cada extensión.
  static String _presetForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return CloudinaryConfig.uploadPresetPdf;
      case 'doc':
      case 'docx':
        return CloudinaryConfig.uploadPresetWord;
      case 'xls':
      case 'xlsx':
        return CloudinaryConfig.uploadPresetExcel;
      default:
        // pptx y otros: sin preset específico, usar el genérico de imagen
        return CloudinaryConfig.uploadPresetImagen;
    }
  }

  /// Indica si la extensión corresponde a un documento Office
  static bool _isOfficeDocument(String extension) {
    const officeExts = {'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'};
    return officeExts.contains(extension.toLowerCase());
  }

  /// Retorna un thumbnail por defecto según el tipo de archivo
  static String _getDefaultThumbnail(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=PDF';
      case 'doc':
      case 'docx':
        return 'https://via.placeholder.com/300x400/4A90E2/FFFFFF?text=WORD';
      case 'xls':
      case 'xlsx':
        return 'https://via.placeholder.com/300x400/4CAF50/FFFFFF?text=EXCEL';
      case 'ppt':
      case 'pptx':
        return 'https://via.placeholder.com/300x400/FF9800/FFFFFF?text=PPT';
      default:
        return 'https://via.placeholder.com/300x400/9E9E9E/FFFFFF?text=FILE';
    }
  }

  /// Validar si un archivo es un documento soportado
  static bool isSupportedDocument(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    const supportedExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx'
    ];
    return supportedExtensions.contains(extension);
  }

  /// Obtener el tipo MIME de un documento
  static String getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  /// Eliminar documento de Cloudinary
  static Future<bool> deleteDocument(String publicId,
      {required bool isPdf}) async {
    try {
      final resourceType = isPdf ? 'image' : 'raw';
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Generar firma para borrado autenticado
      final signature = _generateSignature({
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      });

      final destroyUrl =
          'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/$resourceType/destroy';

      final response = await http.post(
        Uri.parse(destroyUrl),
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
      return false;
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

/// Tipos de documentos soportados
enum DocumentType {
  pdf,
  word,
  excel,
  powerpoint,
  unknown;

  static DocumentType fromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'doc':
      case 'docx':
        return DocumentType.word;
      case 'xls':
      case 'xlsx':
        return DocumentType.excel;
      case 'ppt':
      case 'pptx':
        return DocumentType.powerpoint;
      default:
        return DocumentType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.word:
        return 'Word';
      case DocumentType.excel:
        return 'Excel';
      case DocumentType.powerpoint:
        return 'PowerPoint';
      case DocumentType.unknown:
        return 'Desconocido';
    }
  }
}
