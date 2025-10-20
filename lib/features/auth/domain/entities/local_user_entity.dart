import 'package:equatable/equatable.dart';

class LocalUserEntity extends Equatable {
  final String displayName;
  final String associationId;

  const LocalUserEntity({
    required this.displayName,
    required this.associationId,
  });

  @override
  List<Object?> get props => [displayName, associationId];

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
}
