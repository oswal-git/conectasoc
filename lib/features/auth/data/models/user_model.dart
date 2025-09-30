import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.associationId,
    required super.role,
    required super.status,
    super.language,
    super.timezone,
    required super.dateCreated,
    required super.dateUpdated,
    super.lastLoginDate,
    super.dateDeleted,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.avatarUrl,
    super.authProvider,
    super.notificationSettings,
    super.stats,
  });

  // Convertir desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      associationId: data['associationId'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'member'),
      status: UserStatus.fromString(data['status'] ?? 'active'),
      language: data['language'] ?? 'es',
      timezone: data['timezone'],
      dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      dateUpdated: (data['dateUpdated'] as Timestamp).toDate(),
      lastLoginDate: data['lastLoginDate'] != null
          ? (data['lastLoginDate'] as Timestamp).toDate()
          : null,
      dateDeleted: data['dateDeleted'] != null
          ? (data['dateDeleted'] as Timestamp).toDate()
          : null,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatar'],
      authProvider: data['authProvider'] ?? 'password',
      notificationSettings: data['notificationSettings'] != null
          ? NotificationSettings.fromMap(
              Map<String, dynamic>.from(data['notificationSettings']))
          : const NotificationSettings(),
      stats: data['stats'] != null
          ? UserStats.fromMap(Map<String, dynamic>.from(data['stats']))
          : const UserStats(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'associationId': associationId,
      'role': role.value,
      'status': status.value,
      'language': language,
      'timezone': timezone,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'dateUpdated': Timestamp.fromDate(dateUpdated),
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatarUrl,
      'authProvider': authProvider,
      'notificationSettings': notificationSettings.toMap(),
      'stats': stats.toMap(),
    };

    // Agregar campos opcionales solo si existen
    if (lastLoginDate != null) {
      map['lastLoginDate'] = Timestamp.fromDate(lastLoginDate!);
    }
    if (dateDeleted != null) {
      map['dateDeleted'] = Timestamp.fromDate(dateDeleted!);
    }

    return map;
  }

  // Crear desde Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      associationId: entity.associationId,
      role: entity.role,
      status: entity.status,
      language: entity.language,
      timezone: entity.timezone,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
      lastLoginDate: entity.lastLoginDate,
      dateDeleted: entity.dateDeleted,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      authProvider: entity.authProvider,
      notificationSettings: entity.notificationSettings,
      stats: entity.stats,
    );
  }

  // Convertir a Entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      associationId: associationId,
      role: role,
      status: status,
      language: language,
      timezone: timezone,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      lastLoginDate: lastLoginDate,
      dateDeleted: dateDeleted,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      authProvider: authProvider,
      notificationSettings: notificationSettings,
      stats: stats,
    );
  }
}
