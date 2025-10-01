class Validators {
  // ============================================
  // EMAIL
  // ============================================

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email no válido';
    }

    if (value.length > 254) {
      return 'Email demasiado largo';
    }

    return null;
  }

  // ============================================
  // CONTRASEÑA
  // ============================================

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    if (value.length > 100) {
      return 'Contraseña demasiado larga';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Debe contener mayúsculas, minúsculas y números';
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma la contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // ============================================
  // NOMBRE
  // ============================================

  static String? validateName(String? value, {String fieldName = 'Nombre'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }

    if (value.length > 50) {
      return '$fieldName demasiado largo (máximo 50 caracteres)';
    }

    // Solo letras, espacios, guiones y apóstrofes
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName solo puede contener letras';
    }

    return null;
  }

  // ============================================
  // TELÉFONO
  // ============================================

  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'El teléfono es requerido' : null;
    }

    // Eliminar espacios y caracteres especiales para validación
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanPhone.length < 9 || cleanPhone.length > 15) {
      return 'Teléfono no válido';
    }

    // Solo números y símbolos comunes de teléfono
    final phoneRegex = RegExp(r'^[\d\s\-\(\)\+]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Formato de teléfono no válido';
    }

    return null;
  }

  // ============================================
  // NOMBRE DE ASOCIACIÓN
  // ============================================

  static String? validateAssociationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de la asociación es requerido';
    }

    if (value.trim().length < 3) {
      return 'Mínimo 3 caracteres';
    }

    if (value.length > 100) {
      return 'Nombre demasiado largo (máximo 100 caracteres)';
    }

    return null;
  }

  static String? validateAssociationShortName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre corto es requerido';
    }

    if (value.trim().length < 2) {
      return 'Mínimo 2 caracteres';
    }

    if (value.length > 50) {
      return 'Nombre demasiado largo (máximo 50 caracteres)';
    }

    // Solo letras, números, espacios y guiones
    final shortNameRegex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!shortNameRegex.hasMatch(value)) {
      return 'Solo letras, números, espacios y guiones';
    }

    return null;
  }

  // ============================================
  // CAMPO REQUERIDO GENÉRICO
  // ============================================

  static String? validateRequired(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  // ============================================
  // LONGITUD MÍNIMA
  // ============================================

  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }

    return null;
  }

  // ============================================
  // LONGITUD MÁXIMA
  // ============================================

  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Campo',
  }) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }

    return null;
  }
}
