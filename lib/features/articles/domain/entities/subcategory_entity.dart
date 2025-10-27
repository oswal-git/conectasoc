import 'package:conectasoc/features/articles/domain/entities/entities.dart';

class SubcategoryEntity extends CategoryEntity {
  final String categoryId;

  const SubcategoryEntity(
      {required super.id,
      required super.name,
      required super.order,
      required this.categoryId});

  @override
  SubcategoryEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    int? order,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, order, categoryId];
}
