import 'package:conectasoc/core/errors/errors.dart';
import 'package:conectasoc/features/associations/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteSubcategoryUseCase {
  final SettingsRepository repository;
  DeleteSubcategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String subcategoryId) =>
      repository.deleteSubcategory(subcategoryId);
}
