import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int order;

  const CategoryEntity(
      {required this.id, required this.name, required this.order});

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? order,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, order];

  static CategoryEntity empty() {
    return const CategoryEntity(
      id: '',
      name: '',
      order: 0,
    );
  }
}
