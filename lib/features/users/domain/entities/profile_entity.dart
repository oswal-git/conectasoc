import 'package:equatable/equatable.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart' as auth;

/// Entidad que representa los datos editables del perfil de un usuario.
/// Es un subconjunto de la entidad principal `auth.UserEntity`.
class ProfileEntity extends Equatable {
  final String uid;
  final String name;
  final String lastname;
  final String email; // Generalmente no editable, pero se muestra.
  final String? phone;
  final String language;
  final String? notificationTime1;
  final String? notificationTime2;
  final String? notificationTime3;
  final String? photoUrl;
  final DateTime dateUpdated;

  const ProfileEntity({
    required this.uid,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    required this.language,
    this.notificationTime1,
    this.notificationTime2,
    this.notificationTime3,
    this.photoUrl,
    required this.dateUpdated,
  });

  ProfileEntity copyWith({
    String? uid,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? language,
    String? notificationTime1,
    String? notificationTime2,
    String? notificationTime3,
    String? photoUrl,
    DateTime? dateUpdated,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      notificationTime1: notificationTime1 ?? this.notificationTime1,
      notificationTime2: notificationTime2 ?? this.notificationTime2,
      notificationTime3: notificationTime3 ?? this.notificationTime3,
      photoUrl: photoUrl ?? this.photoUrl,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }

  /// Convierte esta entidad de perfil a la entidad de autenticación.
  /// NOTA: Esto es una simplificación. No puede reconstruir el `UserEntity` completo
  /// (con roles, membresías, etc.), solo los campos que comparte.
  /// Se usa para actualizar el AuthBloc después de un cambio de perfil.
  auth.UserEntity toAuthUser(auth.UserEntity originalAuthUser) {
    return originalAuthUser.copyWith(
      firstName: name,
      lastName: lastname,
      phone: phone,
      language: language,
      notificationTime1: notificationTime1,
      notificationTime2: notificationTime2,
      notificationTime3: notificationTime3,
      avatarUrl: photoUrl, // Asegurarse de que la nueva URL se propaga
      // Se mantiene el resto de la información del usuario original.
      // uid, email, status, memberships, etc. no se modifican aquí.
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        lastname,
        email,
        phone,
        language,
        notificationTime1,
        notificationTime2,
        notificationTime3,
        photoUrl,
        dateUpdated
      ];
}
