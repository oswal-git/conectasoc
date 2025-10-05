// lib/features/auth/domain/entities/membership_entity.dart

import 'package:equatable/equatable.dart';

class MembershipEntity extends Equatable {
  final String associationId;
  final String role;

  const MembershipEntity({
    required this.associationId,
    required this.role,
  });

  @override
  List<Object?> get props => [associationId, role];
}
