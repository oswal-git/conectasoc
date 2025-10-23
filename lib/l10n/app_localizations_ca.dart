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
  String get noAssociationAvailable => 'No hi ha associació disponible';

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

  @override
  String get usersListTitle => 'Llistat d\'usuaris';

  @override
  String get editUser => 'Editar Usuari';

  @override
  String get verifyEmailTitle => 'Verificar Correu';

  @override
  String get verifyEmailHeadline => 'Verifica el teu correu electrònic';

  @override
  String verifyEmailInstruction(Object email) {
    return 'Hem enviat un correu de verificació a $email. Si us plau, revisa la teva bústia d\'entrada i segueix les instruccions per activar el teu compte.';
  }

  @override
  String get resendEmail => 'Reenviar correu';

  @override
  String get verificationEmailSent => 'Correu de verificació reenviat.';

  @override
  String errorResendingEmail(Object error) {
    return 'Error en reenviar el correu: $error';
  }

  @override
  String get status => 'Estat';

  @override
  String get memberships => 'Membresies';

  @override
  String get userHasNoMemberships =>
      'Aquest usuari no pertany a cap associació.';

  @override
  String get roleTitle => 'Rol';

  @override
  String get addMembership => 'Afegir Membresia';

  @override
  String get addMembershipDialogTitle => 'Afegir Membresia';

  @override
  String get selectAssociation => 'Seleccionar associació';

  @override
  String get add => 'Afegir';

  @override
  String get notifications => 'Notificacions';

  @override
  String get never => 'Mai';

  @override
  String get morning => 'Matí';

  @override
  String get afternoon => 'Tarda';

  @override
  String get morningAndAfternoon => 'Matí i Tarda';

  @override
  String get deleteUser => 'Esborrar Usuari';

  @override
  String deleteUserConfirmation(String userName) {
    return 'Estàs segur que vols esborrar $userName? Aquesta acció és irreversible.';
  }

  @override
  String get createUser => 'Crear Usuari';

  @override
  String get password => 'Contrasenya';

  @override
  String get editMode => 'Mode Edició';

  @override
  String get all => 'Totes';

  @override
  String get createArticle => 'Crear Article';

  @override
  String get editArticle => 'Editar Article';

  @override
  String get title => 'Títol';

  @override
  String get abstractContent => 'Resum';

  @override
  String get category => 'Categoria';

  @override
  String get subcategory => 'Subcategoria';

  @override
  String get sections => 'Seccions';

  @override
  String get publishDateLabel => 'Data de Publicació';

  @override
  String get effectiveDateLabel => 'Data d\'Efecte';

  @override
  String get expirationDateLabel => 'Data d\'Expiració (opcional)';

  @override
  String get requiredField => 'Camp requerit';

  @override
  String get selectCoverImage => 'Seleccionar imatge de portada';

  @override
  String get articles => 'Articles';

  @override
  String get deleteArticle => 'Esborrar Article';

  @override
  String get articleTitle => 'Títol de l\'Article';

  @override
  String get articleAbstract => 'Resum de l\'Article';

  @override
  String get coverImage => 'Imatge de Portada';

  @override
  String get articleStatus => 'Estat';

  @override
  String get addSection => 'Afegir Secció';

  @override
  String get removeSection => 'Eliminar Secció';

  @override
  String get reorderSections => 'Reordenar Seccions';

  @override
  String get statusRedaccion => 'En Redacció';

  @override
  String get statusPublicado => 'Publicat';

  @override
  String get statusRevision => 'En Revisió';

  @override
  String get statusExpirado => 'Expirat';

  @override
  String get statusAnulado => 'Anul·lat';

  @override
  String get categoryInformacion => 'Informació';

  @override
  String get categoryNoticias => 'Notícies';

  @override
  String get categoryActas => 'Actes';

  @override
  String get subcategoryServicios => 'Serveis';

  @override
  String get subcategoryCultura => 'Cultura';

  @override
  String get subcategoryReuniones => 'Reunions';

  @override
  String get subcategoryAsambleas => 'Assemblees';

  @override
  String get subcategoryMunicipio => 'Municipi';

  @override
  String get subcategoryUrbanizacion => 'Urbanització';

  @override
  String get searchArticles => 'Cercar articles...';

  @override
  String get filterByCategory => 'Filtrar per categoria';

  @override
  String get articleCreatedSuccess => 'Article creat correctament.';

  @override
  String get articleUpdatedSuccess => 'Article actualitzat correctament.';

  @override
  String get articleDeletedSuccess => 'Article eliminat correctament.';

  @override
  String get titleRequired => 'El títol és obligatori.';

  @override
  String get abstractRequired => 'El resum és obligatori.';

  @override
  String get coverRequired => 'La imatge de portada és obligatòria.';

  @override
  String get categoryRequired => 'La categoria és obligatòria.';

  @override
  String get subcategoryRequired => 'La subcategoria és obligatòria.';

  @override
  String get publicationDateRequired => 'La data de publicació és obligatòria.';

  @override
  String get effectiveDateRequired => 'La data de vigència és obligatòria.';

  @override
  String get publicationDateInvalid =>
      'La data de publicació ha de ser avui o posterior.';

  @override
  String get effectiveDateInvalid =>
      'La data de vigència ha de ser igual o posterior a la de publicació.';

  @override
  String get expirationDateInvalid =>
      'La data de caducitat ha de ser igual o posterior a la de publicació.';

  @override
  String get sectionContentRequired =>
      'Cada secció ha de tenir contingut o una imatge.';

  @override
  String get readMode => 'Mode Lectura';

  @override
  String get section => 'Secció';
}
