// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'ConectAsoc';

  @override
  String get homePage => 'Inici';

  @override
  String get noArticlesYet => 'No hi ha articles per ara.';

  @override
  String get changeAssociation => 'Canviar d\'Associació';

  @override
  String get unknownAssociation => 'Associació desconeguda';

  @override
  String role(Object roleName) {
    return 'Rol: $roleName';
  }

  @override
  String get cancel => 'Cancel·lar';

  @override
  String errorLoadingAssociations(Object error) {
    return 'Error en carregar les associacions: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get createAccount => 'Crear Compte';

  @override
  String get registrationError => 'Error en el Registre';

  @override
  String get accept => 'Acceptar';

  @override
  String get unexpectedError => 'Ha ocorregut un error inesperat.';

  @override
  String get leaveAssociation => 'Abandonar Associació';

  @override
  String get leave => 'Abandonar';

  @override
  String get leaveAssociationConfirmationTitle => 'Confirmar abandó';

  @override
  String leaveAssociationConfirmationMessage(Object associationName) {
    return 'Estàs segur que vols abandonar l\'associació \'$associationName\'? Aquesta acció no es pot desfer.';
  }
}
