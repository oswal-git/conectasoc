import 'category_entity.dart';

class SubcategoryEntity extends CategoryEntity {
  final String categoryId;

  const SubcategoryEntity({
    required super.id,
    required super.name,
    required super.order,
    super.assocId,
    super.isSystem,
    required this.categoryId,
  });

  @override
  SubcategoryEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    int? order,
    String? assocId,
    bool? isSystem,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      order: order ?? this.order,
      assocId: assocId ?? this.assocId,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  List<Object?> get props => [id, name, order, categoryId];

  static SubcategoryEntity empty() {
    return const SubcategoryEntity(
      id: '',
      name: '',
      order: 0,
      categoryId: '',
    );
  }
}
