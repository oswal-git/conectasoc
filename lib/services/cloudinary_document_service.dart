// Extensión del CloudinaryService existente para manejar documentos

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:conectasoc/core/constants/cloudinary_config.dart';

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

  factory CloudinaryDocumentResponse.error(String error) {
    return CloudinaryDocumentResponse(
      success: false,
      error: error,
    );
  }
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

      // Construir la ruta del folder
      final folder = 'documentos/$associationId/$categoryId/$subcategoryId';

      // Subir documento
      final documentResponse = await _uploadToCloudinaryRaw(
        fileBytes: fileBytes,
        filename: filename,
        folder: folder,
        resourceType: 'raw', // Para documentos no-imágenes
      );

      if (!documentResponse.success) {
        return CloudinaryDocumentResponse.error(
            documentResponse.error ?? 'Error al subir documento');
      }

      // Generar thumbnail del documento
      final thumbResponse = await _generateDocumentThumbnail(
        publicId: documentResponse.publicId!,
      );

      return CloudinaryDocumentResponse.success(
        urlDoc: documentResponse.urlDoc!,
        urlThumb: thumbResponse ?? _getDefaultThumbnail(filename),
        publicId: documentResponse.publicId!,
      );
    } catch (e) {
      return CloudinaryDocumentResponse.error('Error subiendo documento: $e');
    }
  }

  /// Subir archivo raw a Cloudinary
  static Future<CloudinaryDocumentResponse> _uploadToCloudinaryRaw({
    required Uint8List fileBytes,
    required String filename,
    required String folder,
    required String resourceType,
  }) async {
    try {
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Parámetros básicos
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['folder'] = folder;
      request.fields['resource_type'] = resourceType;

      // Tags para organización
      request.fields['tags'] = 'document,app:conectasoc';

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
        return CloudinaryDocumentResponse.success(
          urlDoc: responseData['secure_url'] ?? responseData['url'],
          urlThumb: '', // Se generará después
          publicId: responseData['public_id'],
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

  /// Generar thumbnail de un documento
  /// Cloudinary puede generar thumbnails automáticamente para PDFs
  static Future<String?> _generateDocumentThumbnail({
    required String publicId,
  }) async {
    try {
      // Para PDFs, Cloudinary puede generar thumbnails automáticamente
      // Formato: /image/upload/f_jpg,pg_1,w_300,h_400/<public_id>.jpg
      final baseUrl = CloudinaryConfig.uploadUrl
          .replaceAll('/upload', '')
          .replaceAll('/v1_1', '');

      final thumbnailUrl =
          '$baseUrl/image/upload/f_jpg,pg_1,w_300,h_400,c_fit/$publicId.jpg';

      // Verificar si el thumbnail se genera correctamente
      final response = await http.head(Uri.parse(thumbnailUrl));
      if (response.statusCode == 200) {
        return thumbnailUrl;
      }

      return null;
    } catch (e) {
      return null;
    }
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
