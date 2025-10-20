import 'dart:convert';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _localUserKey = 'local_user';
  static const String _isLocalUserKey = 'is_local_user';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Singleton
  static LocalStorageService? _instance;
  static Future<LocalStorageService> getInstance() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService(prefs);
    return _instance!;
  }

  // ============================================
  // USUARIO LOCAL (Tipo 1)
  // ============================================

  /// Guardar usuario local (Tipo 1)
  Future<bool> saveLocalUser(LocalUserEntity user) async {
    try {
      final jsonString = json.encode(user.toMap());
      await _prefs.setString(_localUserKey, jsonString);
      await _prefs.setBool(_isLocalUserKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener usuario local
  LocalUserEntity? getLocalUser() {
    try {
      final jsonString = _prefs.getString(_localUserKey);
      if (jsonString == null) return null;

      final map = json.decode(jsonString) as Map<String, dynamic>;
      return LocalUserEntity.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si hay usuario local guardado
  bool hasLocalUser() {
    return _prefs.getBool(_isLocalUserKey) ?? false;
  }

  /// Eliminar usuario local (al hacer upgrade a Tipo 2)
  Future<bool> deleteLocalUser() async {
    try {
      await _prefs.remove(_localUserKey);
      await _prefs.remove(_isLocalUserKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // PREFERENCIAS GENERALES
  // ============================================

  /// Guardar última asociación seleccionada (útil para login)
  Future<bool> saveLastAssociationId(String associationId) async {
    try {
      await _prefs.setString('last_association_id', associationId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener última asociación seleccionada
  String? getLastAssociationId() {
    return _prefs.getString('last_association_id');
  }

  /// Guardar idioma preferido
  Future<bool> saveLanguage(String language) async {
    try {
      await _prefs.setString('language', language);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener idioma preferido
  String getLanguage() {
    return _prefs.getString('language') ?? 'es';
  }

  /// Limpiar todo el almacenamiento local
  Future<bool> clearAll() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
