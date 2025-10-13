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
  String get leaveAssociationConfirmationTitle => 'Confirmar abandonament';

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
  String get email => 'Email';

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

  @override
  String get changesSavedSuccessfully => 'Canvis desats amb èxit';

  @override
  String get shortName => 'Nom curt';

  @override
  String get longName => 'Nom llarg';

  @override
  String get contactName => 'Nom de contacte';

  @override
  String get saveChanges => 'Desar Canvis';

  @override
  String get associationIdCannotBeEmpty =>
      'L\'ID de l\'associació no pot estar buit.';

  @override
  String get shortAndLongNameRequired =>
      'El nom curt i el nom llarg són obligatoris.';

  @override
  String get invalidEmailFormat => 'El format de l\'email no és vàlid.';

  @override
  String get errorUploadingLogo => 'Error en pujar el logo';

  @override
  String unexpectedErrorOcurred(Object error) {
    return 'Ha ocorregut un error inesperat: $error';
  }

  @override
  String get incompleteAssociationData =>
      'Les dades de la nova associació estan incompletes.';

  @override
  String get mustSelectAnAssociation =>
      'Ha de seleccionar una associació per a unir-s\'hi.';

  @override
  String get welcomeSubtitle => 'Portal d\'Associacions';

  @override
  String get welcomeReadOnlyTitle => 'Només Lectura';

  @override
  String get welcomeReadOnlyDescription => 'Explora contingut sense registre';

  @override
  String get welcomeLoginTitle => 'Iniciar Sessió';

  @override
  String get welcomeLoginDescription => 'Ja tinc un compte';

  @override
  String get welcomeRegisterDescription => 'Registre complet amb notificacions';

  @override
  String get exitReadOnlyMode => 'Sortir del mode lectura';

  @override
  String get createAssociation => 'Crear Associació';

  @override
  String get deleteAssociation => 'Esborrar Associació';

  @override
  String deleteAssociationConfirmation(Object associationName) {
    return 'Estàs segur que vols esborrar l\'associació \'$associationName\'? Aquesta acció no es pot desfer.';
  }

  @override
  String get associationHasUsersError =>
      'No es pot esborrar l\'associació perquè té usuaris assignats.';

  @override
  String get associationDeletedSuccessfully => 'Associació esborrada amb èxit.';

  @override
  String get delete => 'Esborrar';

  @override
  String get undo => 'Desfer';

  @override
  String get contactPerson => 'Persona de contacte';
}
