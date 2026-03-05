import 'package:conectasoc/features/users/domain/entities/entities.dart';
import 'package:equatable/equatable.dart';

class LocalUserEntity extends Equatable implements IUser {
  final String displayName;
  final String associationId;
  @override
  final String language;

  const LocalUserEntity({
    required this.displayName,
    required this.associationId,
    required this.language,
  });

  @override
  List<Object?> get props => [displayName, associationId, language];

  @override
  List<String> get associationIds => [associationId];

  @override
  bool get canEditContent => false; // Un usuario local nunca puede editar.

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'associationId': associationId,
      'language': language,
    };
  }

  factory LocalUserEntity.fromMap(Map<String, dynamic> map) {
    return LocalUserEntity(
      displayName: map['displayName'] as String,
      associationId: map['associationId'] as String,
      language: (map['language'] as String?) ?? 'es',
    );
  }

  @override
  String get uid => 'guest_$associationId'; // ID temporal para el invitado

  @override
  bool get isSuperAdmin => false;
}
