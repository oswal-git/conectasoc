// lib/features/auth/domain/entities/user_entity.dart

import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

enum UserStatus {
  active('active'),
  inactive('inactive'),
  pending('pending'),
  suspended('suspended');

  const UserStatus(this.value);
  final String value;
}

class UserEntity extends Equatable implements IUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final Map<String, String> memberships;
  final UserStatus status;
  final String language;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final DateTime? lastLoginDate;
  final int notificationTime;
  final int configVersion;
  final bool isEmailVerified;
  final String password;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    this.memberships = const {},
    this.status = UserStatus.pending,
    this.language = 'es',
    required this.dateCreated,
    required this.dateUpdated,
    this.lastLoginDate,
    this.notificationTime = 0, // 0 = none
    this.configVersion = 1,
    this.isEmailVerified = false,
    this.password = '',
  });

  // Factory constructor for creating an empty instance
  factory UserEntity.empty() {
    final now = DateTime.now();
    return UserEntity(
      uid: '',
      email: '',
      firstName: '',
      lastName: '',
      phone: '',
      avatarUrl: '',
      memberships: const {},
      status: UserStatus.pending,
      language: 'es',
      dateCreated: now,
      dateUpdated: now,
      lastLoginDate: now,
      notificationTime: 0,
      configVersion: 1,
      isEmailVerified: false,
      password: '',
    );
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    Map<String, String>? memberships,
    UserStatus? status,
    String? language,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    DateTime? lastLoginDate,
    int? notificationTime,
    int? configVersion,
    bool? isEmailVerified,
    String? password,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberships: memberships ?? this.memberships,
      status: status ?? this.status,
      language: language ?? this.language,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      notificationTime: notificationTime ?? this.notificationTime,
      configVersion: configVersion ?? this.configVersion,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      password: password ?? this.password,
    );
  }

  ProfileEntity toProfileEntity() {
    return ProfileEntity(
      uid: uid,
      name: firstName,
      lastname: lastName,
      email: email,
      phone: phone,
      language: language,
      photoUrl: avatarUrl,
    );
  }

  // Helper getters
  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final names = fullName.split(' ').where((n) => n.isNotEmpty);
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first.substring(0, 1).toUpperCase();
    return (names.first.substring(0, 1) + names.last.substring(0, 1))
        .toUpperCase();
  }

  MembershipEntity? getMembershipForAssociation(String associationId) {
    if (memberships.containsKey(associationId)) {
      return MembershipEntity(
        userId: uid,
        associationId: associationId,
        role: memberships[associationId]!,
      );
    }
    return null;
  }

  @override
  bool get isSuperAdmin =>
      memberships.values.any((role) => role == 'superadmin');
  bool get isLocalUser => false; // Overridden by LocalUserEntity
  // Getter para saber si el usuario tiene permisos de edición de contenido
  @override
  bool get canEditContent {
    return memberships.values.any(
        (role) => role == 'superadmin' || role == 'admin' || role == 'editor');
  }

  @override
  List<String> get associationIds => memberships.keys.toList();

  @override
  List<Object?> get props => [
        uid,
        email,
        firstName,
        lastName,
        phone,
        avatarUrl,
        memberships,
        status,
        language,
        dateCreated,
        dateUpdated,
        lastLoginDate,
        notificationTime,
        configVersion,
        isEmailVerified,
      ];
}
