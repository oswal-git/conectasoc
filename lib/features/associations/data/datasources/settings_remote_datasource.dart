import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/exceptions.dart';
import 'package:conectasoc/features/articles/data/models/models.dart';

abstract class SettingsRemoteDataSource {
  Future<void> createCategory(String name);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> reorderCategories(List<CategoryModel> categories);

  Future<void> createSubcategory(String name, String categoryId);
  Future<void> updateSubcategory(SubcategoryModel subcategory);
  Future<void> deleteSubcategory(String subcategoryId);
  Future<void> reorderSubcategories(List<SubcategoryModel> subcategories);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirebaseFirestore firestore;

  SettingsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createCategory(String name) async {
    final categoriesCollection = firestore.collection('categories');
    final countSnapshot = await categoriesCollection.count().get();
    await categoriesCollection.add({
      'name': name,
      'order': countSnapshot.count,
    });
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await firestore
        .collection('categories')
        .doc(category.id)
        .update({'name': category.name, 'order': category.order});
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Check if any article is using this category
    final articlesSnapshot = await firestore
        .collection('articles')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    if (articlesSnapshot.docs.isNotEmpty) {
      throw ServerException(
          'No se puede borrar la categoría, está siendo usada por uno o más artículos.');
    }

    await firestore.collection('categories').doc(categoryId).delete();
  }

  @override
  Future<void> reorderCategories(List<CategoryModel> categories) async {
    final batch = firestore.batch();
    for (var i = 0; i < categories.length; i++) {
      final docRef = firestore.collection('categories').doc(categories[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  @override
  Future<void> createSubcategory(String name, String categoryId) async {
    final subcategoriesCollection = firestore.collection('subcategories');
    final countSnapshot = await subcategoriesCollection
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get();
    await subcategoriesCollection.add({
      'name': name,
      'categoryId': categoryId,
      'order': countSnapshot.count,
    });
  }

  @override
  Future<void> updateSubcategory(SubcategoryModel subcategory) async {
    await firestore
        .collection('subcategories')
        .doc(subcategory.id)
        .update({'name': subcategory.name, 'order': subcategory.order});
  }

  @override
  Future<void> deleteSubcategory(String subcategoryId) async {
    final articlesSnapshot = await firestore
        .collection('articles')
        .where('subcategoryId', isEqualTo: subcategoryId)
        .limit(1)
        .get();

    if (articlesSnapshot.docs.isNotEmpty) {
      throw ServerException(
          'No se puede borrar la subcategoría, está siendo usada por uno o más artículos.');
    }

    await firestore.collection('subcategories').doc(subcategoryId).delete();
  }

  @override
  Future<void> reorderSubcategories(
      List<SubcategoryModel> subcategories) async {
    final batch = firestore.batch();
    for (var i = 0; i < subcategories.length; i++) {
      final docRef =
          firestore.collection('subcategories').doc(subcategories[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }
}
