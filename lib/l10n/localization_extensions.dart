import 'package:conectasoc/features/documents/domain/entities/document_entity.dart';
import 'package:conectasoc/l10n/app_localizations.dart';

extension ReadScopeLocalization on AppLocalizations {
  String readScopeLabel(ReadScope scope) {
    switch (scope) {
      case ReadScope.superadmin:
        return readScopeSuperadmin;
      case ReadScope.admin:
        return readScopeAdmin;
      case ReadScope.editor:
        return readScopeEditor;
      case ReadScope.asociado:
        return readScopeAsociado;
    }
  }
}
