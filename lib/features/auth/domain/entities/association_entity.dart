import 'package:equatable/equatable.dart';

class AssociationEntity extends Equatable {
  final String id;
  final String longName;
  final String shortName;
  final String? description;
  final String? logoUrl;
  final String? website;

  // Contacto
  final String email;
  final String contactName;
  final String phone;
  final AssociationAddress? address;

  // Configuración
  final AssociationSettings settings;

  // Timestamps
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final DateTime? dateDeleted;

  // Estadísticas
  final AssociationStats stats;

  const AssociationEntity({
    required this.id,
    required this.longName,
    required this.shortName,
    this.description,
    this.logoUrl,
    this.website,
    required this.email,
    required this.contactName,
    required this.phone,
    this.address,
    this.settings = const AssociationSettings(),
    required this.dateCreated,
    required this.dateUpdated,
    this.dateDeleted,
    this.stats = const AssociationStats(),
  });

  bool get isActive => dateDeleted == null;

  AssociationEntity copyWith({
    String? id,
    String? longName,
    String? shortName,
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
    return AssociationEntity(
      id: id ?? this.id,
      longName: longName ?? this.longName,
      shortName: shortName ?? this.shortName,
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

  @override
  List<Object?> get props => [
        id,
        longName,
        shortName,
        description,
        logoUrl,
        website,
        email,
        contactName,
        phone,
        address,
        settings,
        dateCreated,
        dateUpdated,
        dateDeleted,
        stats,
      ];
}

class AssociationAddress extends Equatable {
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;

  const AssociationAddress({
    this.street,
    this.city,
    this.postalCode,
    this.country,
  });

  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  AssociationAddress copyWith({
    String? street,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return AssociationAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory AssociationAddress.fromJson(Map<String, dynamic> map) {
    return AssociationAddress(
      street: map['street'],
      city: map['city'],
      postalCode: map['postalCode'],
      country: map['country'],
    );
  }

  @override
  List<Object?> get props => [street, city, postalCode, country];
}

class AssociationSettings extends Equatable {
  final bool allowSelfRegistration;
  final bool requireApproval;
  final int? maxMembers;
  final List<String> featuredCategories;

  const AssociationSettings({
    this.allowSelfRegistration = true,
    this.requireApproval = false,
    this.maxMembers,
    this.featuredCategories = const [],
  });

  AssociationSettings copyWith({
    bool? allowSelfRegistration,
    bool? requireApproval,
    int? maxMembers,
    List<String>? featuredCategories,
  }) {
    return AssociationSettings(
      allowSelfRegistration:
          allowSelfRegistration ?? this.allowSelfRegistration,
      requireApproval: requireApproval ?? this.requireApproval,
      maxMembers: maxMembers ?? this.maxMembers,
      featuredCategories: featuredCategories ?? this.featuredCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowSelfRegistration': allowSelfRegistration,
      'requireApproval': requireApproval,
      'maxMembers': maxMembers,
      'featuredCategories': featuredCategories,
    };
  }

  factory AssociationSettings.fromJson(Map<String, dynamic> map) {
    return AssociationSettings(
      allowSelfRegistration: map['allowSelfRegistration'] ?? true,
      requireApproval: map['requireApproval'] ?? false,
      maxMembers: map['maxMembers'],
      featuredCategories: List<String>.from(map['featuredCategories'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
        allowSelfRegistration,
        requireApproval,
        maxMembers,
        featuredCategories,
      ];
}

class AssociationStats extends Equatable {
  final int totalMembers;
  final int activeMembers;
  final int totalArticles;
  final int publishedArticles;

  const AssociationStats({
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.totalArticles = 0,
    this.publishedArticles = 0,
  });

  AssociationStats copyWith({
    int? totalMembers,
    int? activeMembers,
    int? totalArticles,
    int? publishedArticles,
  }) {
    return AssociationStats(
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      totalArticles: totalArticles ?? this.totalArticles,
      publishedArticles: publishedArticles ?? this.publishedArticles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'totalArticles': totalArticles,
      'publishedArticles': publishedArticles,
    };
  }

  factory AssociationStats.fromJson(Map<String, dynamic> map) {
    return AssociationStats(
      totalMembers: map['totalMembers'] ?? 0,
      activeMembers: map['activeMembers'] ?? 0,
      totalArticles: map['totalArticles'] ?? 0,
      publishedArticles: map['publishedArticles'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalMembers,
        activeMembers,
        totalArticles,
        publishedArticles,
      ];
}
