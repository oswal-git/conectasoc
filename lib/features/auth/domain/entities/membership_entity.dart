// lib\features\auth\domain\entities\membership_entity.dart

import 'package:equatable/equatable.dart';

class MembershipEntity extends Equatable {
  final String userId;
  final String associationId;
  final String role;

  const MembershipEntity({
    required this.userId,
    required this.associationId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, associationId, role];
}

/// Extension to easily convert a MapEntry to a MembershipEntity.
extension MembershipMapEntryExtension on MapEntry<String, String> {
  /// Converts a MapEntry from a user's memberships map into a MembershipEntity.
  /// Requires the [userId] to be passed in, as it's not part of the MapEntry.
  MembershipEntity toMembershipEntity({required String userId}) {
    return MembershipEntity(
      userId: userId,
      associationId: key,
      role: value,
    );
  }
}
