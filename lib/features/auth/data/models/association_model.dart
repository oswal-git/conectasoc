import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/auth/domain/entities/association_entity.dart';

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
    super.settings,
    required super.dateCreated,
    required super.dateUpdated,
    super.dateDeleted,
    super.stats,
  });

  // Convertir desde Firestore
  factory AssociationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AssociationModel(
      id: doc.id,
      longName: data['longName'] ?? '',
      shortName: data['shortName'] ?? '',
      description: data['description'],
      logoUrl: data['logo'],
      website: data['website'],
      email: data['email'] ?? '',
      contactName: data['contactName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] != null
          ? AssociationAddress.fromMap(
              Map<String, dynamic>.from(data['address']))
          : null,
      settings: data['settings'] != null
          ? AssociationSettings.fromMap(
              Map<String, dynamic>.from(data['settings']))
          : const AssociationSettings(),
      dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      dateUpdated: (data['dateUpdated'] as Timestamp).toDate(),
      dateDeleted: data['dateDeleted'] != null
          ? (data['dateDeleted'] as Timestamp).toDate()
          : null,
      stats: data['stats'] != null
          ? AssociationStats.fromMap(Map<String, dynamic>.from(data['stats']))
          : const AssociationStats(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'longName': longName,
      'shortName': shortName,
      'description': description,
      'logo': logoUrl,
      'website': website,
      'email': email,
      'contactName': contactName,
      'phone': phone,
      'settings': settings.toMap(),
      'dateCreated': Timestamp.fromDate(dateCreated),
      'dateUpdated': Timestamp.fromDate(dateUpdated),
      'stats': stats.toMap(),
    };

    // Campos opcionales
    if (address != null) {
      map['address'] = address!.toMap();
    }
    if (dateDeleted != null) {
      map['dateDeleted'] = Timestamp.fromDate(dateDeleted!);
    }

    return map;
  }

  // Crear desde Entity
  factory AssociationModel.fromEntity(AssociationEntity entity) {
    return AssociationModel(
      id: entity.id,
      longName: entity.longName,
      shortName: entity.shortName,
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

  // Convertir a Entity
  AssociationEntity toEntity() {
    return AssociationEntity(
      id: id,
      longName: longName,
      shortName: shortName,
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
}
