// lib/features/auth/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.memberships,
    required super.status,
    required super.dateCreated,
    required super.dateUpdated,
    required super.isEmailVerified,
    super.phone,
    super.notificationFrequency,
    super.fechaNotificada,
    super.configVersion,
    super.avatarUrl,
    super.lastLoginDate,
    super.language,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc,
      {bool isEmailVerified = false}) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely parse memberships
    final Map<String, String> memberships =
        Map<String, String>.from(data['memberships'] ?? {});

    // Safely parse status
    final String statusString = data['status'] ?? 'inactive';
    final UserStatus status = UserStatus.values.firstWhere(
      (e) => e.value == statusString,
      orElse: () => UserStatus.inactive,
    );

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatarUrl'],
      memberships: memberships,
      status: status,
      language: data['language'] ?? 'es',
      dateCreated:
          (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateUpdated:
          (data['dateUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginDate: (data['lastLoginDate'] as Timestamp?)?.toDate(),
      notificationFrequency: data['notificationFrequency'] ?? 'none',
      fechaNotificada: (data['fechaNotificada'] as Timestamp?)?.toDate(),
      configVersion: data['configVersion'] ?? 1,
      isEmailVerified: isEmailVerified, // Set from parameter
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      memberships: entity.memberships,
      status: entity.status,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
      isEmailVerified: entity.isEmailVerified,
      language: entity.language,
      notificationFrequency: entity.notificationFrequency,
      fechaNotificada: entity.fechaNotificada,
      configVersion: entity.configVersion,
      // La contraseña no se incluye en el modelo de datos, solo se usa en la entidad para la creación.
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'memberships': memberships,
      'status': status.value,
      'language': language,
      'dateCreated':
          dateCreated, // Use existing dateCreated instead of total reset
      'dateUpdated': FieldValue.serverTimestamp(),
      'notificationFrequency': notificationFrequency,
      'fechaNotificada':
          fechaNotificada != null ? Timestamp.fromDate(fechaNotificada!) : null,
      'configVersion': configVersion,
      'lastLoginDate':
          lastLoginDate != null ? Timestamp.fromDate(lastLoginDate!) : null,
    };
  }
}
