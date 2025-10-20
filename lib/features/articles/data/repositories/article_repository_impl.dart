import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conectasoc/core/errors/failures.dart';
import 'package:conectasoc/features/articles/data/models/article_model.dart';
import 'package:conectasoc/features/articles/domain/entities/article_entity.dart';
import 'package:conectasoc/features/articles/domain/repositories/article_repository.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore firestore;

  ArticleRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticles({
    UserEntity? user,
    MembershipEntity? membership,
  }) async {
    try {
      Query query = firestore
          .collection('articles')
          .where('status', isEqualTo: 'publicado')
          .where('effectiveDate', isLessThanOrEqualTo: DateTime.now())
          .orderBy('effectiveDate', descending: true);

      // Filtrado por permisos
      if (user == null || user is LocalUserEntity) {
        // No logueado o usuario local: solo genéricos o de su asociación
        final assocId = switch (user) {
          LocalUserEntity localUser => localUser.associationId,
          _ => '',
        };
        query = query.where('assocId', whereIn: ['', assocId]);
      } else if (user.isSuperAdmin) {
        // Superadmin ve todo, no se aplica filtro de asociación
      } else {
        // Usuario autenticado: genéricos + los de sus asociaciones
        final userAssociationIds = user.memberships.keys.toList();
        query = query.where('assocId', whereIn: ['', ...userAssociationIds]);
      }

      final snapshot = await query.get();

      final articles = snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .where((article) {
        // Filtro de expiración en el cliente
        return article.expirationDate == null ||
            article.expirationDate!.isAfter(DateTime.now());
      }).toList();

      return Right(articles);
    } catch (e) {
      return Left(ServerFailure('Error al obtener los artículos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final snapshot =
          await firestore.collection('categories').orderBy('order').get();
      final categories =
          snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener las categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      String categoryId) async {
    try {
      final snapshot = await firestore
          .collection('subcategories')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order')
          .get();
      final subcategories = snapshot.docs
          .map((doc) => SubcategoryModel.fromFirestore(doc))
          .toList();
      return Right(subcategories);
    } catch (e) {
      return Left(ServerFailure('Error al obtener las subcategorías: $e'));
    }
  }
}
