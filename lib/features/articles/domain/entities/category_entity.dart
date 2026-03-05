import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int order;
  final String? assocId;
  final bool isSystem;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.order,
    this.assocId,
    this.isSystem = false,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? order,
    String? assocId,
    bool? isSystem,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      assocId: assocId ?? this.assocId,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  List<Object?> get props => [id, name, order, assocId, isSystem];

  static CategoryEntity empty() {
    return const CategoryEntity(
      id: '',
      name: '',
      order: 0,
      assocId: null,
      isSystem: false,
    );
  }
}
