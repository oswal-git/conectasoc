import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class AssociationEditEvent extends Equatable {
  const AssociationEditEvent();

  @override
  List<Object> get props => [];
}

class LoadAssociationDetails extends AssociationEditEvent {
  final String associationId;
  const LoadAssociationDetails(this.associationId);

  @override
  List<Object> get props => [associationId];
}

class ShortNameChanged extends AssociationEditEvent {
  final String shortName;
  const ShortNameChanged(this.shortName);
}

class LongNameChanged extends AssociationEditEvent {
  final String longName;
  const LongNameChanged(this.longName);
}

class EmailChanged extends AssociationEditEvent {
  final String email;
  const EmailChanged(this.email);
}

class ContactNameChanged extends AssociationEditEvent {
  final String contactName;
  const ContactNameChanged(this.contactName);
}

class PhoneChanged extends AssociationEditEvent {
  final String phone;
  const PhoneChanged(this.phone);
}

class ContactPersonChanged extends AssociationEditEvent {
  final String userId;
  const ContactPersonChanged(this.userId);
}

class LogoChanged extends AssociationEditEvent {
  final Uint8List? imageBytes;
  const LogoChanged(this.imageBytes);
}

class LoadAssociationUsers extends AssociationEditEvent {
  final String associationId;
  const LoadAssociationUsers(this.associationId);
}

class SaveChanges extends AssociationEditEvent {}

class CreateAssociation extends AssociationEditEvent {}

class DeleteCurrentAssociation extends AssociationEditEvent {}
