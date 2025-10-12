import 'package:equatable/equatable.dart';

class AssociationEntity extends Equatable {
  final String id;
  final String shortName;
  final String longName;
  final String? email;
  final String? contactName;
  final String? phone;
  final String? logoUrl;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final DateTime? dateDeleted;

  const AssociationEntity({
    required this.id,
    required this.shortName,
    required this.longName,
    this.email,
    this.contactName,
    this.phone,
    this.logoUrl,
    required this.dateCreated,
    required this.dateUpdated,
    this.dateDeleted,
  });

  // Factory constructor for creating an empty instance
  factory AssociationEntity.empty() {
    final now = DateTime.now();
    return AssociationEntity(
      id: '',
      shortName: '',
      longName: '',
      email: '',
      contactName: '',
      phone: '',
      logoUrl: '',
      dateCreated: now,
      dateUpdated: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shortName,
        longName,
        email,
        contactName,
        phone,
        logoUrl,
        dateCreated,
        dateUpdated,
        dateDeleted,
      ];

  AssociationEntity copyWith({
    String? id,
    String? shortName,
    String? longName,
    String? email,
    String? contactName,
    String? phone,
    String? logoUrl,
  }) {
    return AssociationEntity(
      id: id ?? this.id,
      shortName: shortName ?? this.shortName,
      longName: longName ?? this.longName,
      email: email ?? this.email,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      dateDeleted: dateDeleted,
    );
  }
}
