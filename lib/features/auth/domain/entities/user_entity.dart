import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

enum UserRole {
  superadmin,
  admin,
  editor,
  asociado;

  String get value {
    switch (this) {
      case UserRole.superadmin:
        return 'superadmin';
      case UserRole.admin:
        return 'admin';
      case UserRole.editor:
        return 'editor';
      case UserRole.asociado:
        return 'asociado';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'superadmin':
        return UserRole.superadmin;
      case 'admin':
        return UserRole.admin;
      case 'editor':
        return UserRole.editor;
      case 'asociado':
        return UserRole.asociado;
      default:
        return UserRole.asociado;
    }
  }

  bool get canManageUsers =>
      this == UserRole.superadmin || this == UserRole.admin;
  bool get canManageAssociations => this == UserRole.superadmin;
  bool get canListAllAssociations =>
      this == UserRole.superadmin; // For future use
  bool get canEditArticles =>
      this == UserRole.superadmin ||
      this == UserRole.admin ||
      this == UserRole.editor;
  bool get canCreateArticles =>
      this == UserRole.superadmin ||
      this == UserRole.admin ||
      this == UserRole.editor;
  bool get canCreateGlobalArticles =>
      this == UserRole.superadmin; // Artículos sin asociación
  bool get canEditAllArticles => this == UserRole.superadmin;
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending;

  String get value {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.pending:
        return 'pending';
    }
  }

  static UserStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }
}

// Usuario Tipo 2 - Registrado en Firebase (SIMPLIFICADO)
class UserEntity extends Equatable {
  final String uid;
  final UserStatus status;
  final String language;
  final String? timezone;

  // Timestamps
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final DateTime? lastLoginDate;
  final DateTime? dateDeleted;

  // Datos del usuario (SIEMPRE obligatorios para usuarios Firebase)
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;

  // Metadata
  final String authProvider;

  // Configuraciones
  final NotificationSettings notificationSettings;
  final UserStats stats;

  final List<MembershipEntity> memberships;

  const UserEntity({
    required this.uid,
    required this.status,
    this.language = 'es',
    this.timezone,
    required this.dateCreated,
    required this.dateUpdated,
    this.lastLoginDate,
    this.dateDeleted,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    this.authProvider = 'password',
    this.notificationSettings = const NotificationSettings(),
    this.stats = const UserStats(),
    required this.memberships,
  });

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  bool get isSuperAdmin => memberships.any((m) => m.role == 'superadmin');
  bool get isAdmin => memberships.any((m) => m.role == 'admin');
  bool get isEditor => memberships.any((m) => m.role == 'editor');
  bool get isAssociated => memberships.any((m) => m.role == 'asociado');
  bool get isActive => status == UserStatus.active;

  UserEntity copyWith({
    String? uid,
    UserStatus? status,
    String? language,
    String? timezone,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    DateTime? lastLoginDate,
    DateTime? dateDeleted,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? authProvider,
    NotificationSettings? notificationSettings,
    UserStats? stats,
    List<MembershipEntity>? memberships,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      status: status ?? this.status,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      dateDeleted: dateDeleted ?? this.dateDeleted,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      stats: stats ?? this.stats,
      memberships: memberships ?? this.memberships,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        status,
        language,
        timezone,
        dateCreated,
        dateUpdated,
        lastLoginDate,
        dateDeleted,
        email,
        firstName,
        lastName,
        phone,
        avatarUrl,
        authProvider,
        notificationSettings,
        stats,
        memberships,
      ];
}

// Usuario Tipo 1 - Local (Sin Firebase)
class LocalUserEntity extends Equatable {
  final String displayName;
  final String associationId;

  const LocalUserEntity({
    required this.displayName,
    required this.associationId,
  });

  LocalUserEntity copyWith({
    String? displayName,
    String? associationId,
  }) {
    return LocalUserEntity(
      displayName: displayName ?? this.displayName,
      associationId: associationId ?? this.associationId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'associationId': associationId,
    };
  }

  factory LocalUserEntity.fromMap(Map<String, dynamic> map) {
    return LocalUserEntity(
      displayName: map['displayName'] ?? '',
      associationId: map['associationId'] ?? '',
    );
  }

  @override
  List<Object?> get props => [displayName, associationId];
}

class NotificationSettings extends Equatable {
  final bool push;
  final bool email;
  final String preferredTime;
  final List<String> categories;

  const NotificationSettings({
    this.push = true,
    this.email = false,
    this.preferredTime = 'morning',
    this.categories = const [],
  });

  NotificationSettings copyWith({
    bool? push,
    bool? email,
    String? preferredTime,
    List<String>? categories,
  }) {
    return NotificationSettings(
      push: push ?? this.push,
      email: email ?? this.email,
      preferredTime: preferredTime ?? this.preferredTime,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'push': push,
      'email': email,
      'preferredTime': preferredTime,
      'categories': categories,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      push: map['push'] ?? true,
      email: map['email'] ?? false,
      preferredTime: map['preferredTime'] ?? 'morning',
      categories: List<String>.from(map['categories'] ?? []),
    );
  }

  @override
  List<Object?> get props => [push, email, preferredTime, categories];
}

class UserStats extends Equatable {
  final int articlesRead;
  final DateTime? lastArticleRead;
  final int totalNotifications;
  final int unreadNotifications;

  const UserStats({
    this.articlesRead = 0,
    this.lastArticleRead,
    this.totalNotifications = 0,
    this.unreadNotifications = 0,
  });

  UserStats copyWith({
    int? articlesRead,
    DateTime? lastArticleRead,
    int? totalNotifications,
    int? unreadNotifications,
  }) {
    return UserStats(
      articlesRead: articlesRead ?? this.articlesRead,
      lastArticleRead: lastArticleRead ?? this.lastArticleRead,
      totalNotifications: totalNotifications ?? this.totalNotifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articlesRead': articlesRead,
      'lastArticleRead': lastArticleRead?.toIso8601String(),
      'totalNotifications': totalNotifications,
      'unreadNotifications': unreadNotifications,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      articlesRead: map['articlesRead'] ?? 0,
      lastArticleRead: map['lastArticleRead'] != null
          ? DateTime.parse(map['lastArticleRead'])
          : null,
      totalNotifications: map['totalNotifications'] ?? 0,
      unreadNotifications: map['unreadNotifications'] ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [articlesRead, lastArticleRead, totalNotifications, unreadNotifications];
}
