import 'dart:typed_data';
import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/l10n/app_localizations.dart';
import 'package:equatable/equatable.dart';

abstract class ArticleEditEvent extends Equatable {
  const ArticleEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticleForEdit extends ArticleEditEvent {
  final String articleId;
  const LoadArticleForEdit(this.articleId);
  @override
  List<Object?> get props => [articleId];
}

class AutoSaveDraft extends ArticleEditEvent {
  const AutoSaveDraft();
}

class ArticleFieldChanged extends ArticleEditEvent {
  final ArticleEntity article;

  const ArticleFieldChanged(this.article);

  @override
  List<Object?> get props => [article];
}

class CategoryChanged extends ArticleEditEvent {
  final String categoryId;

  const CategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SubcategoryChanged extends ArticleEditEvent {
  final String subcategoryId;

  const SubcategoryChanged(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

class PublishDateChanged extends ArticleEditEvent {
  final DateTime date;
  const PublishDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class EffectiveDateChanged extends ArticleEditEvent {
  final DateTime date;
  const EffectiveDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class ExpirationDateChanged extends ArticleEditEvent {
  final DateTime? date;
  const ExpirationDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class PrepareArticleCreation extends ArticleEditEvent {}

class SaveArticle extends ArticleEditEvent {
  // El archivo de la imagen de portada, si se ha seleccionado uno nuevo.
  final AppLocalizations l10n;

  const SaveArticle(this.l10n);

  @override
  List<Object?> get props => [l10n];
}

class DeleteArticle extends ArticleEditEvent {
  final String articleId;
  const DeleteArticle(this.articleId);
  @override
  List<Object?> get props => [articleId];
}

class UpdateCoverImage extends ArticleEditEvent {
  final Uint8List? newCoverImageBytes;
  const UpdateCoverImage(this.newCoverImageBytes);
  @override
  List<Object?> get props => [newCoverImageBytes];
}

class SetArticleStatus extends ArticleEditEvent {
  final ArticleStatus status;
  const SetArticleStatus(this.status);
  @override
  List<Object?> get props => [status];
}

class AddSection extends ArticleEditEvent {
  const AddSection();
}

class RemoveSection extends ArticleEditEvent {
  final String sectionId;
  const RemoveSection(this.sectionId);
  @override
  List<Object?> get props => [sectionId];
}

class ReorderSectionsEvent extends ArticleEditEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderSectionsEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class UpdateSectionContent extends ArticleEditEvent {
  final String sectionId;
  final String richTextContent;
  const UpdateSectionContent(this.sectionId, this.richTextContent);
  @override
  List<Object?> get props => [sectionId, richTextContent];
}

class UpdateSectionImage extends ArticleEditEvent {
  final String sectionId;
  final Uint8List? imageBytes;
  const UpdateSectionImage(this.sectionId, this.imageBytes);
  @override
  List<Object?> get props => [sectionId, imageBytes];
}

class RestoreDraft extends ArticleEditEvent {
  const RestoreDraft();
}

class DiscardDraft extends ArticleEditEvent {
  final ArticleEntity originalArticle;
  const DiscardDraft(this.originalArticle);

  @override
  List<Object?> get props => [originalArticle];
}

class TogglePreviewMode extends ArticleEditEvent {
  const TogglePreviewMode();
}
