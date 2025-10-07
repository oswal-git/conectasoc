// lib/features/auth/data/models/association_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/associations/domain/entities/association_entity.dart';

class AssociationModel extends AssociationEntity {
  const AssociationModel({
    required super.id,
    required super.longName,
    required super.shortName,
    super.description,
    super.logoUrl,
    super.website,
    required super.email,
    required super.contactName,
    required super.phone,
    super.address,
    super.settings = const AssociationSettings(),
    required super.dateCreated,
    required super.dateUpdated,
    super.dateDeleted,
    super.stats = const AssociationStats(),
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
      contactName: data['contactName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] != null
          ? AssociationAddress.fromJson(data['address'])
          : null,
      settings: data['settings'] != null
          ? AssociationSettings.fromJson(data['settings'])
          : const AssociationSettings(),
      dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      dateUpdated: (data['dateUpdated'] as Timestamp).toDate(),
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
      description: description,
      logoUrl: logoUrl,
      website: website,
      email: email,
      contactName: contactName,
      phone: phone,
      address: address,
      settings: settings,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      dateDeleted: dateDeleted,
      stats: stats,
    );
  }

  // Crear desde Entity
  factory AssociationModel.fromEntity(AssociationEntity entity) {
    return AssociationModel(
      id: entity.id,
      shortName: entity.shortName,
      longName: entity.longName,
      description: entity.description,
      logoUrl: entity.logoUrl,
      website: entity.website,
      email: entity.email,
      contactName: entity.contactName,
      phone: entity.phone,
      address: entity.address,
      settings: entity.settings,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
      dateDeleted: entity.dateDeleted,
      stats: entity.stats,
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
