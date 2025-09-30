class CloudinaryConfig {
  // ⚠️ REEMPLAZA ESTOS VALORES CON LOS DE TU CUENTA CLOUDINARY
  static const String cloudName = 'dcxhxr6de'; // Ejemplo: 'dq2xgf7zk'
  static const String uploadPreset =
      'conectasoc_preset'; // El preset que creaste
  static const String apiKey =
      '131463626424237'; // Solo para operaciones autenticadas
  static const String apiSecret =
      '5PEf5Dtow5AK4qxcUiJylQS7l8Q'; // ¡NUNCA expongas en producción!

  // URLs de la API
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  static String get destroyUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';

  // Configuración de límites
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 800;

  // Calidades de compresión
  static const int normalQuality = 80;

  // Formatos permitidos
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Método para obtener URL con transformaciones
  static String getTransformedUrl(
      String originalUrl, Map<String, String> transformations) {
    if (transformations.isEmpty) return originalUrl;

    final transformString =
        transformations.entries.map((e) => '${e.key}_${e.value}').join(',');

    return originalUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/$transformString/',
    );
  }

  // Método para obtener URLs de diferentes tamaños
  static Map<String, String> getImageUrls(String originalUrl) {
    return {
      'original': originalUrl,
      'large': getTransformedUrl(originalUrl, {'w': '1200', 'q': 'auto'}),
      'medium': getTransformedUrl(originalUrl, {'w': '800', 'q': 'auto'}),
      'small': getTransformedUrl(originalUrl, {'w': '400', 'q': 'auto'}),
      'thumbnail':
          getTransformedUrl(originalUrl, {'w': '150', 'h': '150', 'c': 'fill'}),
    };
  }
}

// Enum para tipos de imagen (simplificado)
enum CloudinaryImageType {
  avatar,
  articleCover,
  general;

  String get folder {
    switch (this) {
      case CloudinaryImageType.avatar:
        return 'conectasoc/avatars';
      case CloudinaryImageType.articleCover:
        return 'conectasoc/articles';
      case CloudinaryImageType.general:
        return 'conectasoc/general';
    }
  }
}

// Clase para respuesta de Cloudinary (simplificada)
class CloudinaryResponse {
  final bool success;
  final String? publicId;
  final String? url;
  final String? secureUrl;
  final int? width;
  final int? height;
  final int? bytes;
  final String? error;

  const CloudinaryResponse({
    required this.success,
    this.publicId,
    this.url,
    this.secureUrl,
    this.width,
    this.height,
    this.bytes,
    this.error,
  });

  factory CloudinaryResponse.success(Map<String, dynamic> response) {
    return CloudinaryResponse(
      success: true,
      publicId: response['public_id'],
      url: response['url'],
      secureUrl: response['secure_url'],
      width: response['width'],
      height: response['height'],
      bytes: response['bytes'],
    );
  }

  factory CloudinaryResponse.error(String error) {
    return CloudinaryResponse(
      success: false,
      error: error,
    );
  }
}
