import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.order,
  });

  factory CategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(id: id, name: name, order: order);
  }
}

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.name,
    required super.order,
    required super.categoryId,
  });

  factory SubcategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SubcategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      categoryId: data['categoryId'] ?? '',
    );
  }

  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
        id: id, name: name, order: order, categoryId: categoryId);
  }
}
