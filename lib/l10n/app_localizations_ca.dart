// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get abstractCharLimitExceeded =>
      'El resum no pot excedir els 200 caràcters.';

  @override
  String get abstractContent => 'Resum';

  @override
  String get abstractRequired => 'El resum és obligatori.';

  @override
  String get accept => 'Acceptar';

  @override
  String get add => 'Afegir';

  @override
  String get addMembership => 'Afegir Membresia';

  @override
  String get addMembershipDialogTitle => 'Afegir Membresia';

  @override
  String get addSection => 'Afegir Secció';

  @override
  String get afternoon => 'Tarda';

  @override
  String get all => 'Totes';

  @override
  String get appTitle => 'ConectAsoc';

  @override
  String get articleAbstract => 'Resum de l\'Article';

  @override
  String get articleCreatedSuccess => 'Article creat correctament.';

  @override
  String get articleDeletedSuccess => 'Article eliminat correctament.';

  @override
  String get articleStatus => 'Estat';

  @override
  String get articleTitle => 'Article';

  @override
  String get articleUpdatedSuccess => 'Article actualitzat correctament.';

  @override
  String get articles => 'Articles';

  @override
  String get association => 'Associació';

  @override
  String get associationDeletedSuccessfully => 'Associació esborrada amb èxit.';

  @override
  String get associationHasUsersError =>
      'No es pot esborrar l\'associació perquè té usuaris assignats.';

  @override
  String get associationIdCannotBeEmpty =>
      'L\'ID de l\'associació no pot estar buit.';

  @override
  String get associations => 'Associacions';

  @override
  String get associationsListTitle => 'Llistat d\'associacions';

  @override
  String get camera => 'Càmera';

  @override
  String get canDownload => 'Permetre descàrrega';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get category => 'Categoria';

  @override
  String get categoryActas => 'Actes';

  @override
  String get categoryInformacion => 'Informació';

  @override
  String get categoryNoticias => 'Notícies';

  @override
  String get categoryRequired => 'La categoria és obligatòria.';

  @override
  String get changeAssociation => 'Canviar d\'Associació';

  @override
  String get changesSavedSuccessfully => 'Canvis desats amb èxit';

  @override
  String get configuration => 'Configuració';

  @override
  String get confirmPassword => 'Confirmar Contrasenya *';

  @override
  String get confirmSave => 'Confirmar desat';

  @override
  String get confirmSaveMessage => 'Estàs segur que vols desar els canvis?';

  @override
  String get contact => 'Contacte';

  @override
  String get contactEmail => 'Email de Contacte';

  @override
  String get contactName => 'Nom de contacte';

  @override
  String get contactPerson => 'Persona de contacte';

  @override
  String get contactPhone => 'Telèfon de Contacte';

  @override
  String get continueEditing => 'Continuar editant';

  @override
  String get coverImage => 'Imatge de Portada';

  @override
  String get coverRequired => 'La imatge de portada és obligatòria.';

  @override
  String get createAccount => 'Crear Compte';

  @override
  String get createArticle => 'Crear Article';

  @override
  String get createAssociation => 'Crear Associació';

  @override
  String get createGeneralAssociation =>
      'Crear Associació General (SuperAdmin)';

  @override
  String get createNewAssociation => 'Crear nova associació';

  @override
  String get createUser => 'Crear Usuari';

  @override
  String get cropImage => 'Retallar Imatge';

  @override
  String get delete => 'Esborrar';

  @override
  String get deleteArticle => 'Esborrar Article';

  @override
  String get deleteAssociation => 'Esborrar Associació';

  @override
  String deleteAssociationConfirmation(Object associationName) {
    return 'Estàs segur que vols esborrar l\'associació \'$associationName\'? Aquesta acció no es pot desfer.';
  }

  @override
  String get deleteUser => 'Esborrar Usuari';

  @override
  String deleteUserConfirmation(String userName) {
    return 'Estàs segur que vols esborrar $userName? Aquesta acció és irreversible.';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get discardChanges => 'Descartar canvis';

  @override
  String get documentDescription => 'Descripció del document';

  @override
  String get documentDescriptionHint =>
      'Descriu el contingut del document (màxim 200 caràcters)';

  @override
  String get documentDetails => 'Detalls del document';

  @override
  String get documentIncompatible =>
      'Una secció no pot tenir document i contingut (imatge/text) alhora';

  @override
  String get documentList => 'Llista de documents';

  @override
  String get documentNotAvailable => 'Document no disponible';

  @override
  String get documentUploaded => 'Document pujat amb èxit';

  @override
  String get documents => 'Documents';

  @override
  String get downloadDocument => 'Descarregar document';

  @override
  String get draftFoundMessage =>
      'Hem trobat un esborrany sense desar. Vols restaurar-lo?';

  @override
  String get draftFoundTitle => 'Esborrany Trobat';

  @override
  String get edit => 'Editar';

  @override
  String get editArticle => 'Editar Article';

  @override
  String get editMode => 'Mode Edició';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get editUser => 'Editar Usuari';

  @override
  String get effectiveDateInvalid =>
      'La data de vigència ha de ser igual o posterior a la de publicació.';

  @override
  String get effectiveDateLabel => 'Data d\'Efecte';

  @override
  String get effectiveDateRequired => 'La data de vigència és obligatòria.';

  @override
  String get effectivePublishDate => 'Data de vigència de la publicació';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'el-teu@email.com';

  @override
  String errorLoadingAssociations(Object error) {
    return 'Error en carregar les associacions: $error';
  }

  @override
  String errorResendingEmail(Object error) {
    return 'Error en reenviar el correu: $error';
  }

  @override
  String get errorUploadingLogo => 'Error en pujar el logo';

  @override
  String get exitReadOnlyMode => 'Sortir del mode lectura';

  @override
  String get expirationDateInvalid =>
      'La data de caducitat ha de ser igual o posterior a la de publicació.';

  @override
  String get expirationDateLabel => 'Data d\'Expiració (opcional)';

  @override
  String get fileSize => 'Mida de l\'arxiu';

  @override
  String get filter => 'Filtro';

  @override
  String get filterByCategory => 'Filtrar per categoria';

  @override
  String get from => 'del';

  @override
  String get gallery => 'Galeria';

  @override
  String get genericError => 'Ha hagut un problema en carregar les dades.';

  @override
  String get homePage => 'Inici';

  @override
  String get incompleteAssociationData =>
      'Les dades de la nova associació estan incompletes.';

  @override
  String get invalidEmailFormat => 'El format de l\'email no és vàlid.';

  @override
  String get joinAssociation => 'Unir-se a Associació';

  @override
  String get langCatalan => 'Català';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get language => 'Idioma';

  @override
  String get lastname => 'Cognoms';

  @override
  String get leave => 'Abandonar';

  @override
  String get leaveAssociation => 'Abandonar Associació';

  @override
  String leaveAssociationConfirmationMessage(Object associationName) {
    return 'Estàs segur que vols abandonar l\'associació \'$associationName\'? Aquesta acció no es pot desfer.';
  }

  @override
  String get leaveAssociationConfirmationTitle => 'Confirmar abandonament';

  @override
  String get leaveWithoutSaving => 'Sortir sense desar';

  @override
  String get linkDocument => 'Enllaçar document';

  @override
  String get login => 'Accedir';

  @override
  String get logout => 'Tancar Sessió';

  @override
  String get longName => 'Nom llarg';

  @override
  String get longNameHint => 'Ex: Associació de Veïns 2024';

  @override
  String get memberships => 'Membresies';

  @override
  String get morning => 'Matí';

  @override
  String get morningAndAfternoon => 'Matí i Tarda';

  @override
  String get mustSelectAnAssociation =>
      'Ha de seleccionar una associació per a unir-s\'hi.';

  @override
  String get myProfile => 'El Meu Perfil';

  @override
  String get name => 'Nom';

  @override
  String get never => 'Mai';

  @override
  String get newAssociationData => 'Dades de la Nova Associació';

  @override
  String get noArticlesYet => 'No hi ha articles per ara.';

  @override
  String get noAssociationAvailable => 'No hi ha associació disponible';

  @override
  String get noAssociationsAvailableToJoin =>
      'No hi ha associacions disponibles. N\'has de crear una de nova.';

  @override
  String get noChangesToSave => 'No hi ha res modificat per guardar';

  @override
  String get noDocumentsFound => 'No s\'han trobat documents';

  @override
  String get noResultsFound => 'No s\'han trobat resultats';

  @override
  String get notificationFreqNone => 'No rebre notificacions';

  @override
  String get notificationFreqOnce => 'Una vegada al dia (12:00)';

  @override
  String get notificationFreqThrice => 'Tres vegades (10:00, 15:00, 20:00)';

  @override
  String get notificationFreqTwice => 'Dues vegades (10:00 i 20:00)';

  @override
  String get notifications => 'Notificacions';

  @override
  String get optionalUseYourEmail => 'Opcional (s\'usarà el teu email)';

  @override
  String get optionalUseYourName => 'Opcional (s\'usarà el teu nom)';

  @override
  String get optionalUseYourPhone => 'Opcional (s\'usarà el teu telèfon)';

  @override
  String get password => 'Contrasenya';

  @override
  String get passwordMinLength => 'Mínim 6 caràcters';

  @override
  String get passwordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get personalData => 'Dades Personals';

  @override
  String get phone => 'Telèfon';

  @override
  String get preview => 'Previsualitzar Article';

  @override
  String get previewMode => 'Previsualitzar';

  @override
  String get profileLoadError => 'Error en carregar el perfil.';

  @override
  String get profileSavedSuccess => 'Perfil desat amb èxit';

  @override
  String get publicationDateInvalid =>
      'La data de publicació ha de ser avui o posterior.';

  @override
  String get publicationDateRequired => 'La data de publicació és obligatòria.';

  @override
  String get publishDateLabel => 'Data de Publicació';

  @override
  String get readMode => 'Mode Lectura';

  @override
  String get readScope => 'Àmbit de lectura';

  @override
  String get readScopeAdmin => 'Admin i superiors';

  @override
  String get readScopeAdminHelp =>
      'Visible per a superadmin i admin de l\'associació';

  @override
  String get readScopeAsociado => 'Tots de l\'associació';

  @override
  String get readScopeAsociadoHelp =>
      'Visible per a tots els membres de l\'associació';

  @override
  String get readScopeEditor => 'Editor i superiors';

  @override
  String get readScopeEditorHelp =>
      'Visible per a superadmin, admin i editors de l\'associació';

  @override
  String get readScopeSuperadmin => 'Només Superadmin';

  @override
  String get readScopeSuperadminHelp => 'Només visible per a superadmin';

  @override
  String get register => 'Registrar-se';

  @override
  String get registrationError => 'Error en el Registre';

  @override
  String get registrationSuccessMessage =>
      'Registre reeixit. Si us plau, verifica el teu correu electrònic.';

  @override
  String get removeDocumentLink => 'Treure enllaç a document';

  @override
  String get removeSection => 'Eliminar Secció';

  @override
  String get removeSectionConfirmation =>
      'Estàs segur que vols eliminar aquesta secció? Aquesta acció no es pot desfer.';

  @override
  String get reorderSections => 'Reordenar Seccions';

  @override
  String get requiredField => 'Camp requerit';

  @override
  String get resendEmail => 'Reenviar correu';

  @override
  String get restore => 'Restaurar';

  @override
  String get retry => 'Reintentar';

  @override
  String role(Object roleName) {
    return 'Rol: $roleName';
  }

  @override
  String get roleTitle => 'Rol';

  @override
  String get save => 'Desar';

  @override
  String get saveChanges => 'Desar Canvis';

  @override
  String get search => 'Cercar...';

  @override
  String get searchArticles => 'Cercar articles...';

  @override
  String get searchDocument => 'Cercar document';

  @override
  String get section => 'Secció';

  @override
  String get sectionContentRequired =>
      'Cada secció ha de tenir contingut o una imatge.';

  @override
  String get sections => 'Seccions';

  @override
  String get selectAssociation => 'Seleccionar associació';

  @override
  String get selectCoverImage => 'Seleccionar imatge de portada';

  @override
  String get selectDocument => 'Seleccionar document';

  @override
  String get shortAndLongNameRequired =>
      'El nom curt i el nom llarg són obligatoris.';

  @override
  String get shortName => 'Nom curt';

  @override
  String get shortNameHint => 'Ex: ASSOC2024';

  @override
  String get start => 'a partir de';

  @override
  String get status => 'Estat';

  @override
  String get statusAnulado => 'Anul·lat';

  @override
  String get statusExpirado => 'Expirat';

  @override
  String get statusNotificar => 'Publicar i Notificar';

  @override
  String get statusNotificarShort => 'Notificar';

  @override
  String get statusPublicado => 'Publicat';

  @override
  String get statusRedaccion => 'En Redacció';

  @override
  String get statusRevision => 'En Revisió';

  @override
  String get stay => 'Quedar-se';

  @override
  String get subcategory => 'Subcategoria';

  @override
  String get subcategoryAsambleas => 'Assemblees';

  @override
  String get subcategoryCultura => 'Cultura';

  @override
  String get subcategoryMunicipio => 'Municipi';

  @override
  String get subcategoryRequired => 'La subcategoria és obligatòria.';

  @override
  String get subcategoryReuniones => 'Reunions';

  @override
  String get subcategoryServicios => 'Serveis';

  @override
  String get subcategoryUrbanizacion => 'Urbanització';

  @override
  String get title => 'Títol';

  @override
  String get titleCharLimitExceeded =>
      'El títol no pot excedir els 100 caràcters.';

  @override
  String get titleRequired => 'El títol és obligatori.';

  @override
  String get toThe => 'al';

  @override
  String get undo => 'Desfer';

  @override
  String get unexpectedError => 'Ha ocorregut un error inesperat.';

  @override
  String unexpectedErrorOcurred(Object error) {
    return 'Ha ocorregut un error inesperat: $error';
  }

  @override
  String get unknownAssociation => 'Associació desconeguda';

  @override
  String get unsavedChanges => 'Canvis sense desar';

  @override
  String get unsavedChangesMessage =>
      'Tens canvis sense desar. Vols sortir sense desar-los?';

  @override
  String get unsavedChangesTitle => 'Canvis sense desar';

  @override
  String get uploadDocuments => 'Pujar documents';

  @override
  String get uploadNewDocument => 'Pujar document nou';

  @override
  String get uploadedBy => 'Pujat per';

  @override
  String get uploadDateFormat => 'dd \'de\' MMMM \'de\' y, \'a les\' HH:mm:ss';

  @override
  String userDeleted(Object userName) {
    return 'Usuari $userName eliminat';
  }

  @override
  String get userHasNoMemberships =>
      'Aquest usuari no pertany a cap associació.';

  @override
  String get users => 'Usuaris';

  @override
  String get usersListTitle => 'Llistat d\'usuaris';

  @override
  String get verificationEmailSent => 'Correu de verificació reenviat.';

  @override
  String get verifyEmailHeadline => 'Verifica el teu correu electrònic';

  @override
  String verifyEmailInstruction(Object email) {
    return 'Hem enviat un correu de verificació a $email. Si us plau, revisa la teva bústia d\'entrada i segueix les instruccions per activar el teu compte.';
  }

  @override
  String get verifyEmailTitle => 'Verificar Correu';

  @override
  String get viewDocument => 'Veure document';

  @override
  String get welcomeLoginDescription => 'Ja tinc un compte';

  @override
  String get welcomeLoginTitle => 'Iniciar Sessió';

  @override
  String get welcomeReadOnlyDescription => 'Explora contingut sense registre';

  @override
  String get welcomeReadOnlyTitle => 'Només Lectura';

  @override
  String get welcomeRegisterDescription => 'Registre complet amb notificacions';

  @override
  String get welcomeSubtitle => 'Portal d\'Associacions';

  @override
  String get youWillBeAdmin => 'Seràs l\'administrador de l\'associació';
}
