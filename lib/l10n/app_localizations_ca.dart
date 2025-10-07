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

  @override
  String get users => 'Usuaris';

  @override
  String get associations => 'Associacions';

  @override
  String get myProfile => 'El Meu Perfil';

  @override
  String get joinAssociation => 'Unir-se a Associació';

  @override
  String get logout => 'Tancar Sessió';

  @override
  String get login => 'Accedir';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get profileSavedSuccess => 'Perfil desat amb èxit';

  @override
  String get profileLoadError => 'Error en carregar el perfil.';

  @override
  String get name => 'Nom';

  @override
  String get lastname => 'Cognoms';

  @override
  String get email => 'Correu electrònic';

  @override
  String get phone => 'Telèfon';

  @override
  String get language => 'Idioma';

  @override
  String get langSpanish => 'Español';

  @override
  String get langEnglish => 'English';

  @override
  String get langCatalan => 'Català';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Càmera';

  @override
  String get cropImage => 'Retallar Imatge';

  @override
  String get association => 'Associació';

  @override
  String get search => 'Cercar...';

  @override
  String get contact => 'Contacte';

  @override
  String get noResultsFound => 'No s\'han trobat resultats';

  @override
  String get associationsListTitle => 'Llistat d\'associacions';
}
