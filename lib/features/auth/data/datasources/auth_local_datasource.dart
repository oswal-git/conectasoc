// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/core/services/local_storage_service.dart';
import 'package:conectasoc/features/auth/data/models/user_model.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();

  // Usuario local (Tipo 1)
  Future<void> saveLocalUser(LocalUserEntity localUser);
  Future<LocalUserEntity?> getLocalUser();
  Future<bool> hasLocalUser();
  Future<void> deleteLocalUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService localStorage;

  AuthLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // Aquí podrías implementar caché si lo necesitas
      // Por ahora delegamos al localStorage
    } catch (e) {
      throw CacheException('Error guardando usuario en caché: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      // Implementar si necesitas caché
      return null;
    } catch (e) {
      throw CacheException('Error obteniendo usuario de caché: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteLocalUser();
    } catch (e) {
      throw CacheException('Error limpiando caché: $e');
    }
  }

  @override
  Future<void> saveLocalUser(LocalUserEntity localUser) async {
    try {
      await localStorage.saveLocalUser(localUser);
      await localStorage.saveLastAssociationId(localUser.associationId);
    } catch (e) {
      throw CacheException('Error guardando usuario local: $e');
    }
  }

  @override
  Future<LocalUserEntity?> getLocalUser() async {
    try {
      return localStorage.getLocalUser();
    } catch (e) {
      throw CacheException('Error obteniendo usuario local: $e');
    }
  }

  @override
  Future<bool> hasLocalUser() async {
    try {
      return localStorage.hasLocalUser();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteLocalUser() async {
    try {
      await localStorage.deleteLocalUser();
    } catch (e) {
      throw CacheException('Error eliminando usuario local: $e');
    }
  }
}
