// lib/features/associations/data/models/association_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';

class AssociationModel extends AssociationEntity {
  final String? description;
  final String? website;
  final AssociationAddress? address;
  final AssociationSettings settings;
  final AssociationStats stats;

  const AssociationModel({
    required super.id,
    required super.longName,
    required super.shortName,
    super.logoUrl,
    required super.email,
    super.contactUserId,
    required super.contactName,
    required super.phone,
    required super.dateCreated,
    required super.dateUpdated,
    super.dateDeleted,
    this.description,
    this.website,
    this.address,
    this.settings = const AssociationSettings(),
    this.stats = const AssociationStats(),
  });

  // Crear desde Firestore DocumentSnapshot
  factory AssociationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AssociationModel(
      id: doc.id,
      shortName: data['shortName'] ?? '',
      longName: data['longName'] ?? '',
      description: data['description'],
      logoUrl: data['logoUrl'],
      website: data['website'],
      email: data['email'] ?? '',
      contactUserId: data['contactUserId'],
      contactName: data['contactName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] != null
          ? AssociationAddress.fromJson(data['address'])
          : null,
      settings: data['settings'] != null
          ? AssociationSettings.fromJson(data['settings'])
          : const AssociationSettings(),
      dateCreated: data['dateCreated'] is Timestamp
          ? (data['dateCreated'] as Timestamp).toDate()
          : DateTime.now(),
      dateUpdated: data['dateUpdated'] is Timestamp
          ? (data['dateUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      dateDeleted: data['dateDeleted'] != null
          ? (data['dateDeleted'] as Timestamp).toDate()
          : null,
      stats: data['stats'] != null
          ? AssociationStats.fromJson(data['stats'])
          : const AssociationStats(),
    );
  }

  // Crear desde JSON
  factory AssociationModel.fromJson(Map<String, dynamic> json) {
    return AssociationModel(
      id: json['id'] ?? '',
      shortName: json['shortName'] ?? '',
      longName: json['longName'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      website: json['website'],
      email: json['email'] ?? '',
      contactUserId: json['contactUserId'],
      contactName: json['contactName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null
          ? AssociationAddress.fromJson(json['address'])
          : null,
      settings: json['settings'] != null
          ? AssociationSettings.fromJson(json['settings'])
          : const AssociationSettings(),
      dateCreated: DateTime.parse(json['dateCreated']),
      dateUpdated: DateTime.parse(json['dateUpdated']),
      dateDeleted: json['dateDeleted'] != null
          ? DateTime.parse(json['dateDeleted'])
          : null,
      stats: json['stats'] != null
          ? AssociationStats.fromJson(json['stats'])
          : const AssociationStats(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'shortName': shortName,
      'longName': longName,
      'description': description,
      'logoUrl': logoUrl,
      'website': website,
      'email': email,
      'contactUserId': contactUserId,
      'contactName': contactName,
      'phone': phone,
      'address': address?.toJson(),
      'settings': settings.toJson(),
      'dateCreated': Timestamp.fromDate(dateCreated),
      'dateUpdated': Timestamp.fromDate(dateUpdated),
      'dateDeleted':
          dateDeleted != null ? Timestamp.fromDate(dateDeleted!) : null,
      'stats': stats.toJson(),
    };
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortName': shortName,
      'longName': longName,
      'description': description,
      'logoUrl': logoUrl,
      'website': website,
      'email': email,
      'contactUserId': contactUserId,
      'contactName': contactName,
      'phone': phone,
      'address': address?.toJson(),
      'settings': settings.toJson(),
      'dateCreated': dateCreated.toIso8601String(),
      'dateUpdated': dateUpdated.toIso8601String(),
      'dateDeleted': dateDeleted?.toIso8601String(),
      'stats': stats.toJson(),
    };
  }

  // Convertir a Entity
  AssociationEntity toEntity() {
    return AssociationEntity(
      id: id,
      shortName: shortName,
      longName: longName,
      logoUrl: logoUrl,
      email: email,
      contactUserId: contactUserId,
      contactName: contactName,
      phone: phone,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      dateDeleted: dateDeleted,
    );
  }

  // Crear desde Entity
  factory AssociationModel.fromEntity(AssociationEntity entity) {
    return AssociationModel(
      id: entity.id,
      shortName: entity.shortName,
      longName: entity.longName,
      logoUrl: entity.logoUrl,
      email: entity.email,
      contactUserId: entity.contactUserId,
      contactName: entity.contactName,
      phone: entity.phone,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
      dateDeleted: entity.dateDeleted,
    );
  }

  // CopyWith para crear copias modificadas
  @override
  AssociationModel copyWith({
    String? id,
    String? shortName,
    String? longName,
    String? description,
    String? logoUrl,
    String? website,
    String? contactUserId,
    String? email,
    String? contactName,
    String? phone,
    AssociationAddress? address,
    AssociationSettings? settings,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    DateTime? dateDeleted,
    AssociationStats? stats,
  }) {
    return AssociationModel(
      id: id ?? this.id,
      shortName: shortName ?? this.shortName,
      longName: longName ?? this.longName,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      contactUserId: contactUserId ?? this.contactUserId,
      email: email ?? this.email,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      settings: settings ?? this.settings,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      dateDeleted: dateDeleted ?? this.dateDeleted,
      stats: stats ?? this.stats,
    );
  }
}

// Clases de soporte que no necesitan ser entidades porque son parte de Association

class AssociationAddress {
  final String street;
  final String city;
  final String state;
  final String zip;

  const AssociationAddress(
      {required this.street,
      required this.city,
      required this.state,
      required this.zip});

  factory AssociationAddress.fromJson(Map<String, dynamic> json) =>
      AssociationAddress(
        street: json['street'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        zip: json['zip'] ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'street': street, 'city': city, 'state': state, 'zip': zip};
}

class AssociationSettings {
  final bool allowPublicRegistration;

  const AssociationSettings({this.allowPublicRegistration = true});

  factory AssociationSettings.fromJson(Map<String, dynamic> json) =>
      AssociationSettings(
          allowPublicRegistration: json['allowPublicRegistration'] ?? true);

  Map<String, dynamic> toJson() =>
      {'allowPublicRegistration': allowPublicRegistration};
}

class AssociationStats {
  final int memberCount;

  const AssociationStats({this.memberCount = 0});

  factory AssociationStats.fromJson(Map<String, dynamic> json) =>
      AssociationStats(memberCount: json['memberCount'] ?? 0);

  Map<String, dynamic> toJson() => {'memberCount': memberCount};
}
