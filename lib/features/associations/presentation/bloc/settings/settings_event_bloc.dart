import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettingsData extends SettingsEvent {
  final String? assocId;
  const LoadSettingsData({this.assocId});
  @override
  List<Object> get props => assocId != null ? [assocId!] : [];
}

class AddCategory extends SettingsEvent {
  final String name;
  final String assocId;
  const AddCategory(this.name, this.assocId);
  @override
  List<Object> get props => [name, assocId];
}

class UpdateCategory extends SettingsEvent {
  final String id;
  final String newName;
  const UpdateCategory(this.id, this.newName);
  @override
  List<Object> get props => [id, newName];
}

class DeleteCategory extends SettingsEvent {
  final String id;
  const DeleteCategory(this.id);
  @override
  List<Object> get props => [id];
}

class AddSubcategory extends SettingsEvent {
  final String name;
  final String categoryId;
  final String assocId;
  const AddSubcategory(this.name, this.categoryId, this.assocId);
  @override
  List<Object> get props => [name, categoryId, assocId];
}

class UpdateSubcategory extends SettingsEvent {
  final String id;
  final String newName;
  const UpdateSubcategory(this.id, this.newName);
  @override
  List<Object> get props => [id, newName];
}

class DeleteSubcategory extends SettingsEvent {
  final String id;
  const DeleteSubcategory(this.id);
  @override
  List<Object> get props => [id];
}
