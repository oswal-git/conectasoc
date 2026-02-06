import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/auth/domain/entities/entities.dart';

class ArticlePermissions {
  /// Determines if the current user can edit a specific article.
  ///
  /// Rules:
  /// - superadmin: Edits everything.
  /// - admin: Edits articles of their own association.
  /// - editor: Edits articles of their own association created by them.
  /// - Generales (Superadmin): Only Superadmin can edit (assocId == '').
  /// - asociado: Cannot edit anything.
  static bool canEdit({
    required ArticleEntity article,
    required UserEntity? user,
    required MembershipEntity? membership,
  }) {
    if (user == null) return false;

    // Superadmin has global access
    if (user.isSuperAdmin) {
      return true;
    }

    // If no membership is provided, we can't verify association-level roles
    if (membership == null) return false;

    // Check if the article is general (created by superadmin)
    // General articles have assocId == ''
    if (article.assocId.isEmpty) {
      return false; // Only superadmin (handled above) can edit general articles
    }

    // Role-based logic for association members
    switch (membership.role) {
      case 'admin':
        // Admin can edit any article from their association
        return article.assocId == membership.associationId;
      case 'editor':
        // Editor can only edit their own articles from their association
        return article.assocId == membership.associationId &&
            article.userId == user.uid;
      case 'asociado':
      default:
        return false;
    }
  }
}
