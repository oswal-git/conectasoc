import 'package:equatable/equatable.dart';

/// Ámbito de lectura de un documento (basado en roles)
enum ReadScope {
  superadmin, // Solo superadmin
  admin, // Superadmin + ( admin de la asociación )
  editor, // Superadmin + ( admin + editor de la asociación )
  asociado, // Superadmin + ( todos los de la asociación (incluye visitantes autenticados) )
}

extension ReadScopeExtension on ReadScope {
  String get value => toString().split('.').last;

  static ReadScope fromValue(String value) {
    return ReadScope.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReadScope.asociado, // Por defecto más restrictivo
    );
  }

  /// Orden jerárquico (menor = más restrictivo)
  int get hierarchy {
    switch (this) {
      case ReadScope.superadmin:
        return 0;
      case ReadScope.admin:
        return 1;
      case ReadScope.editor:
        return 2;
      case ReadScope.asociado:
        return 3;
    }
  }

  /// Verifica si este scope permite acceso al usuario según su rol y asociación
  bool allowsAccessFor({
    required bool isSuperAdmin,
    required String? userAssociationId,
    required String documentAssociationId,
    String? userRole, // 'admin', 'editor', 'asociado'
  }) {
    // Superadmin siempre tiene acceso
    if (isSuperAdmin) return true;

    // Si el documento no es de la asociación del usuario, no tiene acceso
    if (userAssociationId != documentAssociationId) return false;

    // Verificar según el ámbito del documento
    switch (this) {
      case ReadScope.superadmin:
        return false; // Solo superadmin (ya se verificó arriba)

      case ReadScope.admin:
        return userRole == 'admin';

      case ReadScope.editor:
        return userRole == 'admin' || userRole == 'editor';

      case ReadScope.asociado:
        return userRole == 'admin' ||
            userRole == 'editor' ||
            userRole == 'asociado';
    }
  }

  /// Etiqueta traducible para UI
  String get displayKey {
    switch (this) {
      case ReadScope.superadmin:
        return 'readScopeSuperadmin';
      case ReadScope.admin:
        return 'readScopeAdmin';
      case ReadScope.editor:
        return 'readScopeEditor';
      case ReadScope.asociado:
        return 'readScopeAsociado';
    }
  }
}

/// Entidad que representa un documento subido al sistema
class DocumentEntity extends Equatable {
  final String id;
  final String publicId; // public_id de Cloudinary para borrado
  final String urlDoc; // URL del documento en Cloudinary
  final String urlThumb; // URL del thumbnail en Cloudinary
  final String descDoc; // Descripción (máximo 200 caracteres)
  final bool canDownload; // Indica si se puede descargar
  final String associationId; // ID de la asociación ("Todas" para superadmin)
  final String categoryId; // ID de la categoría
  final String subcategoryId; // ID de la subcategoría
  final DateTime dateCreation;
  final DateTime dateModification;
  final String uploadedBy; // User ID del que subió el documento
  final String fileName; // Nombre original del archivo
  final String fileExtension; // Extensión del archivo (pdf, docx, xlsx)
  final int fileSize; // Tamaño en bytes
  final ReadScope readScope; // Ámbito de lectura del documento

  const DocumentEntity({
    required this.id,
    required this.publicId,
    required this.urlDoc,
    required this.urlThumb,
    required this.descDoc,
    this.canDownload = true,
    required this.associationId,
    required this.categoryId,
    required this.subcategoryId,
    required this.dateCreation,
    required this.dateModification,
    required this.uploadedBy,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    this.readScope =
        ReadScope.asociado, // ✨ Por defecto: todos de la asociación
  });

  DocumentEntity copyWith({
    String? id,
    String? publicId,
    String? urlDoc,
    String? urlThumb,
    String? descDoc,
    bool? canDownload,
    String? associationId,
    String? categoryId,
    String? subcategoryId,
    DateTime? dateCreation,
    DateTime? dateModification,
    String? uploadedBy,
    String? fileName,
    String? fileExtension,
    int? fileSize,
    ReadScope? readScope,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
      urlDoc: urlDoc ?? this.urlDoc,
      urlThumb: urlThumb ?? this.urlThumb,
      descDoc: descDoc ?? this.descDoc,
      canDownload: canDownload ?? this.canDownload,
      associationId: associationId ?? this.associationId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      readScope: readScope ?? this.readScope,
    );
  }

  @override
  List<Object?> get props => [
        id,
        publicId,
        urlDoc,
        urlThumb,
        descDoc,
        canDownload,
        associationId,
        categoryId,
        subcategoryId,
        dateCreation,
        dateModification,
        uploadedBy,
        fileName,
        fileExtension,
        fileSize,
        readScope,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'urlDoc': urlDoc,
      'urlThumb': urlThumb,
      'descDoc': descDoc,
      'canDownload': canDownload,
      'associationId': associationId,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification.toIso8601String(),
      'uploadedBy': uploadedBy,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'readScope': readScope.value, // ✨ NUEVO
    };
  }

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      id: json['id'] ?? '',
      publicId: json['publicId'] ?? '',
      urlDoc: json['urlDoc'] ?? '',
      urlThumb: json['urlThumb'] ?? '',
      descDoc: json['descDoc'] ?? '',
      canDownload: json['canDownload'] ?? true,
      associationId: json['associationId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subcategoryId: json['subcategoryId'] ?? '',
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      uploadedBy: json['uploadedBy'] ?? '',
      fileName: json['fileName'] ?? '',
      fileExtension: json['fileExtension'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      readScope: ReadScopeExtension.fromValue(
          json['readScope'] ?? 'asociado'), // ✨ NUEVO
    );
  }

  /// Formatea el tamaño del archivo en formato legible
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Retorna el icono apropiado según la extensión del archivo
  String get fileIcon {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      default:
        return '📎';
    }
  }

  static DocumentEntity empty() {
    return DocumentEntity(
      id: '',
      publicId: '',
      urlDoc: '',
      urlThumb: '',
      descDoc: '',
      canDownload: true,
      associationId: '',
      categoryId: '',
      subcategoryId: '',
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
      uploadedBy: '',
      fileName: '',
      fileExtension: '',
      fileSize: 0,
    );
  }
}
