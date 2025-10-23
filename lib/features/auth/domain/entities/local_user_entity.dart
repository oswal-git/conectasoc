import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

class LocalUserEntity extends Equatable implements IUser {
  final String displayName;
  final String associationId;

  const LocalUserEntity({
    required this.displayName,
    required this.associationId,
  });

  @override
  List<Object?> get props => [displayName, associationId];

  @override
  List<String> get associationIds => [associationId];

  @override
  bool get canEditContent => false; // Un usuario local nunca puede editar.

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'associationId': associationId,
    };
  }

  factory LocalUserEntity.fromMap(Map<String, dynamic> map) {
    return LocalUserEntity(
      displayName: map['displayName'] as String,
      associationId: map['associationId'] as String,
    );
  }

  @override
  bool get isSuperAdmin => false;
}
