// lib/features/auth/data/models/membership_model.dart

import 'package:conectasoc/features/auth/domain/entities/membership_entity.dart';

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    required super.associationId,
    required super.role,
  });

  factory MembershipModel.fromMap(Map<String, dynamic> map) {
    return MembershipModel(
      associationId: map['associationId'] ?? '',
      role: map['role'] ?? 'asociado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'associationId': associationId,
      'role': role,
    };
  }
}
