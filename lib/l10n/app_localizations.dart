import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'ConectAsoc'**
  String get appTitle;

  /// No description provided for @homePage.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homePage;

  /// No description provided for @noArticlesYet.
  ///
  /// In es, this message translates to:
  /// **'No hay artículos por ahora.'**
  String get noArticlesYet;

  /// No description provided for @changeAssociation.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de Asociación'**
  String get changeAssociation;

  /// No description provided for @unknownAssociation.
  ///
  /// In es, this message translates to:
  /// **'Asociación desconocida'**
  String get unknownAssociation;

  /// No description provided for @role.
  ///
  /// In es, this message translates to:
  /// **'Rol: {roleName}'**
  String role(Object roleName);

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @errorLoadingAssociations.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las asociaciones: {error}'**
  String errorLoadingAssociations(Object error);

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccount;

  /// No description provided for @registrationError.
  ///
  /// In es, this message translates to:
  /// **'Error en el Registro'**
  String get registrationError;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado.'**
  String get unexpectedError;

  /// No description provided for @leaveAssociation.
  ///
  /// In es, this message translates to:
  /// **'Abandonar Asociación'**
  String get leaveAssociation;

  /// No description provided for @leave.
  ///
  /// In es, this message translates to:
  /// **'Abandonar'**
  String get leave;

  /// No description provided for @leaveAssociationConfirmationTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar abandono'**
  String get leaveAssociationConfirmationTitle;

  /// No description provided for @leaveAssociationConfirmationMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres abandonar la asociación \'{associationName}\'? Esta acción no se puede deshacer.'**
  String leaveAssociationConfirmationMessage(Object associationName);

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @associations.
  ///
  /// In es, this message translates to:
  /// **'Asociaciones'**
  String get associations;

  /// No description provided for @myProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get myProfile;

  /// No description provided for @joinAssociation.
  ///
  /// In es, this message translates to:
  /// **'Unirse a Asociación'**
  String get joinAssociation;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Acceder'**
  String get login;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado con éxito'**
  String get profileSavedSuccess;

  /// No description provided for @profileLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el perfil.'**
  String get profileLoadError;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @lastname.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get lastname;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @langSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @langEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langCatalan.
  ///
  /// In es, this message translates to:
  /// **'Català'**
  String get langCatalan;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @cropImage.
  ///
  /// In es, this message translates to:
  /// **'Recortar Imagen'**
  String get cropImage;

  /// No description provided for @association.
  ///
  /// In es, this message translates to:
  /// **'Asociación'**
  String get association;

  /// No description provided for @noAssociationAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay asociación disponible'**
  String get noAssociationAvailable;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get search;

  /// No description provided for @contact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contact;

  /// No description provided for @noResultsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get noResultsFound;

  /// No description provided for @associationsListTitle.
  ///
  /// In es, this message translates to:
  /// **'Listado de asociaciones'**
  String get associationsListTitle;

  /// No description provided for @changesSavedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados con éxito'**
  String get changesSavedSuccessfully;

  /// No description provided for @shortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre corto'**
  String get shortName;

  /// No description provided for @longName.
  ///
  /// In es, this message translates to:
  /// **'Nombre largo'**
  String get longName;

  /// No description provided for @contactName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de contacto'**
  String get contactName;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get saveChanges;

  /// No description provided for @associationIdCannotBeEmpty.
  ///
  /// In es, this message translates to:
  /// **'El ID de la asociación no puede estar vacío.'**
  String get associationIdCannotBeEmpty;

  /// No description provided for @shortAndLongNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre corto y el nombre largo son obligatorios.'**
  String get shortAndLongNameRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido.'**
  String get invalidEmailFormat;

  /// No description provided for @errorUploadingLogo.
  ///
  /// In es, this message translates to:
  /// **'Error al subir el logo'**
  String get errorUploadingLogo;

  /// Generic error message with a placeholder for the specific error.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado: {error}'**
  String unexpectedErrorOcurred(Object error);

  /// No description provided for @incompleteAssociationData.
  ///
  /// In es, this message translates to:
  /// **'Los datos de la nueva asociación están incompletos.'**
  String get incompleteAssociationData;

  /// No description provided for @mustSelectAnAssociation.
  ///
  /// In es, this message translates to:
  /// **'Debe seleccionar una asociación para unirse.'**
  String get mustSelectAnAssociation;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Portal de Asociaciones'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeReadOnlyTitle.
  ///
  /// In es, this message translates to:
  /// **'Solo Lectura'**
  String get welcomeReadOnlyTitle;

  /// No description provided for @welcomeReadOnlyDescription.
  ///
  /// In es, this message translates to:
  /// **'Explora contenido sin registro'**
  String get welcomeReadOnlyDescription;

  /// No description provided for @welcomeLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get welcomeLoginTitle;

  /// No description provided for @welcomeLoginDescription.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo una cuenta'**
  String get welcomeLoginDescription;

  /// No description provided for @welcomeRegisterDescription.
  ///
  /// In es, this message translates to:
  /// **'Registro completo con notificaciones'**
  String get welcomeRegisterDescription;

  /// No description provided for @exitReadOnlyMode.
  ///
  /// In es, this message translates to:
  /// **'Salir del modo lectura'**
  String get exitReadOnlyMode;

  /// No description provided for @createAssociation.
  ///
  /// In es, this message translates to:
  /// **'Crear Asociación'**
  String get createAssociation;

  /// No description provided for @deleteAssociation.
  ///
  /// In es, this message translates to:
  /// **'Borrar Asociación'**
  String get deleteAssociation;

  /// No description provided for @deleteAssociationConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres borrar la asociación \'{associationName}\'? Esta acción no se puede deshacer.'**
  String deleteAssociationConfirmation(Object associationName);

  /// No description provided for @associationHasUsersError.
  ///
  /// In es, this message translates to:
  /// **'No se puede borrar la asociación porque tiene usuarios asignados.'**
  String get associationHasUsersError;

  /// No description provided for @associationDeletedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Asociación borrada con éxito.'**
  String get associationDeletedSuccessfully;

  /// Texto para el botón de confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get delete;

  /// The label for an undo action.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// Label for the contact person field or selector.
  ///
  /// In es, this message translates to:
  /// **'Persona de contacto'**
  String get contactPerson;

  /// Title for the user list screen.
  ///
  /// In es, this message translates to:
  /// **'Listado de usuarios'**
  String get usersListTitle;

  /// Title for the user edit screen.
  ///
  /// In es, this message translates to:
  /// **'Editar Usuario'**
  String get editUser;

  /// Title for the email verification screen.
  ///
  /// In es, this message translates to:
  /// **'Verificar Correo'**
  String get verifyEmailTitle;

  /// Headline for the email verification screen.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo electrónico'**
  String get verifyEmailHeadline;

  /// Instructional text on the email verification screen.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un correo de verificación a {email}. Por favor, revisa tu bandeja de entrada y sigue las instrucciones para activar tu cuenta.'**
  String verifyEmailInstruction(Object email);

  /// Button text to resend the verification email.
  ///
  /// In es, this message translates to:
  /// **'Reenviar correo'**
  String get resendEmail;

  /// Snackbar message confirming the verification email was resent.
  ///
  /// In es, this message translates to:
  /// **'Correo de verificación reenviado.'**
  String get verificationEmailSent;

  /// Snackbar message for an error when resending the verification email.
  ///
  /// In es, this message translates to:
  /// **'Error al reenviar el correo: {error}'**
  String errorResendingEmail(Object error);

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @memberships.
  ///
  /// In es, this message translates to:
  /// **'Membresías'**
  String get memberships;

  /// No description provided for @userHasNoMemberships.
  ///
  /// In es, this message translates to:
  /// **'Este usuario no pertenece a ninguna asociación.'**
  String get userHasNoMemberships;

  /// No description provided for @roleTitle.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get roleTitle;

  /// No description provided for @addMembership.
  ///
  /// In es, this message translates to:
  /// **'Añadir Membresía'**
  String get addMembership;

  /// No description provided for @addMembershipDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir Membresía'**
  String get addMembershipDialogTitle;

  /// No description provided for @selectAssociation.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar asociación'**
  String get selectAssociation;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @never.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get never;

  /// No description provided for @morning.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In es, this message translates to:
  /// **'Tarde'**
  String get afternoon;

  /// No description provided for @morningAndAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Mañana y Tarde'**
  String get morningAndAfternoon;

  /// No description provided for @deleteUser.
  ///
  /// In es, this message translates to:
  /// **'Borrar Usuario'**
  String get deleteUser;

  /// Confirmation message for deleting a user.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres borrar a {userName}? Esta acción es irreversible.'**
  String deleteUserConfirmation(String userName);

  /// Title for the user creation screen.
  ///
  /// In es, this message translates to:
  /// **'Crear Usuario'**
  String get createUser;

  /// Label for the password input field.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Label for the switch to toggle editing mode.
  ///
  /// In es, this message translates to:
  /// **'Modo Edición'**
  String get editMode;

  /// Text for the 'All' filter chip.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @createArticle.
  ///
  /// In es, this message translates to:
  /// **'Crear Artículo'**
  String get createArticle;

  /// No description provided for @editArticle.
  ///
  /// In es, this message translates to:
  /// **'Editar Artículo'**
  String get editArticle;

  /// No description provided for @title.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @abstractContent.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get abstractContent;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @subcategory.
  ///
  /// In es, this message translates to:
  /// **'Subcategoría'**
  String get subcategory;

  /// No description provided for @sections.
  ///
  /// In es, this message translates to:
  /// **'Secciones'**
  String get sections;

  /// No description provided for @publishDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Publicación'**
  String get publishDateLabel;

  /// No description provided for @effectiveDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Efecto'**
  String get effectiveDateLabel;

  /// No description provided for @expirationDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Expiración (opcional)'**
  String get expirationDateLabel;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get requiredField;

  /// No description provided for @selectCoverImage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar imagen de portada'**
  String get selectCoverImage;

  /// No description provided for @articles.
  ///
  /// In es, this message translates to:
  /// **'Artículos'**
  String get articles;

  /// No description provided for @deleteArticle.
  ///
  /// In es, this message translates to:
  /// **'Borrar Artículo'**
  String get deleteArticle;

  /// No description provided for @articleTitle.
  ///
  /// In es, this message translates to:
  /// **'Título del Artículo'**
  String get articleTitle;

  /// No description provided for @articleAbstract.
  ///
  /// In es, this message translates to:
  /// **'Resumen del Artículo'**
  String get articleAbstract;

  /// No description provided for @coverImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen de Portada'**
  String get coverImage;

  /// No description provided for @articleStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get articleStatus;

  /// No description provided for @addSection.
  ///
  /// In es, this message translates to:
  /// **'Añadir Sección'**
  String get addSection;

  /// No description provided for @removeSection.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Sección'**
  String get removeSection;

  /// No description provided for @reorderSections.
  ///
  /// In es, this message translates to:
  /// **'Reordenar Secciones'**
  String get reorderSections;

  /// No description provided for @statusRedaccion.
  ///
  /// In es, this message translates to:
  /// **'En Redacción'**
  String get statusRedaccion;

  /// No description provided for @statusPublicado.
  ///
  /// In es, this message translates to:
  /// **'Publicado'**
  String get statusPublicado;

  /// No description provided for @statusRevision.
  ///
  /// In es, this message translates to:
  /// **'En Revisión'**
  String get statusRevision;

  /// No description provided for @statusExpirado.
  ///
  /// In es, this message translates to:
  /// **'Expirado'**
  String get statusExpirado;

  /// No description provided for @statusAnulado.
  ///
  /// In es, this message translates to:
  /// **'Anulado'**
  String get statusAnulado;

  /// No description provided for @categoryInformacion.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get categoryInformacion;

  /// No description provided for @categoryNoticias.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get categoryNoticias;

  /// No description provided for @categoryActas.
  ///
  /// In es, this message translates to:
  /// **'Actas'**
  String get categoryActas;

  /// No description provided for @subcategoryServicios.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get subcategoryServicios;

  /// No description provided for @subcategoryCultura.
  ///
  /// In es, this message translates to:
  /// **'Cultura'**
  String get subcategoryCultura;

  /// No description provided for @subcategoryReuniones.
  ///
  /// In es, this message translates to:
  /// **'Reuniones'**
  String get subcategoryReuniones;

  /// No description provided for @subcategoryAsambleas.
  ///
  /// In es, this message translates to:
  /// **'Asambleas'**
  String get subcategoryAsambleas;

  /// No description provided for @subcategoryMunicipio.
  ///
  /// In es, this message translates to:
  /// **'Municipio'**
  String get subcategoryMunicipio;

  /// No description provided for @subcategoryUrbanizacion.
  ///
  /// In es, this message translates to:
  /// **'Urbanización'**
  String get subcategoryUrbanizacion;

  /// No description provided for @searchArticles.
  ///
  /// In es, this message translates to:
  /// **'Buscar artículos...'**
  String get searchArticles;

  /// No description provided for @filterByCategory.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por categoría'**
  String get filterByCategory;

  /// No description provided for @articleCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Artículo creado correctamente.'**
  String get articleCreatedSuccess;

  /// No description provided for @articleUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Artículo actualizado correctamente.'**
  String get articleUpdatedSuccess;

  /// No description provided for @articleDeletedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Artículo eliminado correctamente.'**
  String get articleDeletedSuccess;

  /// No description provided for @titleRequired.
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio.'**
  String get titleRequired;

  /// No description provided for @abstractRequired.
  ///
  /// In es, this message translates to:
  /// **'El resumen es obligatorio.'**
  String get abstractRequired;

  /// No description provided for @coverRequired.
  ///
  /// In es, this message translates to:
  /// **'La imagen de portada es obligatoria.'**
  String get coverRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In es, this message translates to:
  /// **'La categoría es obligatoria.'**
  String get categoryRequired;

  /// No description provided for @subcategoryRequired.
  ///
  /// In es, this message translates to:
  /// **'La subcategoría es obligatoria.'**
  String get subcategoryRequired;

  /// No description provided for @publicationDateRequired.
  ///
  /// In es, this message translates to:
  /// **'La fecha de publicación es obligatoria.'**
  String get publicationDateRequired;

  /// No description provided for @effectiveDateRequired.
  ///
  /// In es, this message translates to:
  /// **'La fecha de vigencia es obligatoria.'**
  String get effectiveDateRequired;

  /// No description provided for @publicationDateInvalid.
  ///
  /// In es, this message translates to:
  /// **'La fecha de publicación debe ser hoy o posterior.'**
  String get publicationDateInvalid;

  /// No description provided for @effectiveDateInvalid.
  ///
  /// In es, this message translates to:
  /// **'La fecha de vigencia debe ser igual o posterior a la de publicación.'**
  String get effectiveDateInvalid;

  /// No description provided for @expirationDateInvalid.
  ///
  /// In es, this message translates to:
  /// **'La fecha de caducidad debe ser igual o posterior a la de publicación.'**
  String get expirationDateInvalid;

  /// No description provided for @sectionContentRequired.
  ///
  /// In es, this message translates to:
  /// **'Cada sección debe tener contenido o una imagen.'**
  String get sectionContentRequired;

  /// No description provided for @readMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Lectura'**
  String get readMode;

  /// No description provided for @section.
  ///
  /// In es, this message translates to:
  /// **'Sección'**
  String get section;

  /// No description provided for @titleCharLimitExceeded.
  ///
  /// In es, this message translates to:
  /// **'El título no puede exceder los 100 caracteres.'**
  String get titleCharLimitExceeded;

  /// No description provided for @abstractCharLimitExceeded.
  ///
  /// In es, this message translates to:
  /// **'El resumen no puede exceder los 200 caracteres.'**
  String get abstractCharLimitExceeded;

  /// No description provided for @removeSectionConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar esta sección? Esta acción no se puede deshacer.'**
  String get removeSectionConfirmation;

  /// No description provided for @previewMode.
  ///
  /// In es, this message translates to:
  /// **'Previsualizar'**
  String get previewMode;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @draftFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrador encontrado'**
  String get draftFoundTitle;

  /// No description provided for @draftFoundMessage.
  ///
  /// In es, this message translates to:
  /// **'Hemos encontrado un borrador sin guardar. ¿Deseas restaurarlo?'**
  String get draftFoundMessage;

  /// No description provided for @discard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get discard;

  /// No description provided for @restore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @configuration.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuration;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'a partir de'**
  String get start;

  /// No description provided for @toThe.
  ///
  /// In es, this message translates to:
  /// **'al'**
  String get toThe;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'del'**
  String get from;

  /// No description provided for @effectivePublishDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha vigencia publicación'**
  String get effectivePublishDate;

  /// No description provided for @personalData.
  ///
  /// In es, this message translates to:
  /// **'Datos Personales'**
  String get personalData;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get emailHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Contraseña *'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @createNewAssociation.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva asociación'**
  String get createNewAssociation;

  /// No description provided for @youWillBeAdmin.
  ///
  /// In es, this message translates to:
  /// **'Serás administrador de la asociación'**
  String get youWillBeAdmin;

  /// No description provided for @createGeneralAssociation.
  ///
  /// In es, this message translates to:
  /// **'Crear Asociación General (SuperAdmin)'**
  String get createGeneralAssociation;

  /// No description provided for @newAssociationData.
  ///
  /// In es, this message translates to:
  /// **'Datos de la Nueva Asociación'**
  String get newAssociationData;

  /// No description provided for @shortNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: ASOC2024'**
  String get shortNameHint;

  /// No description provided for @longNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Asociación de Vecinos 2024'**
  String get longNameHint;

  /// No description provided for @contactEmail.
  ///
  /// In es, this message translates to:
  /// **'Email de Contacto'**
  String get contactEmail;

  /// No description provided for @optionalUseYourEmail.
  ///
  /// In es, this message translates to:
  /// **'Opcional (se usará tu email)'**
  String get optionalUseYourEmail;

  /// No description provided for @optionalUseYourName.
  ///
  /// In es, this message translates to:
  /// **'Opcional (se usará tu nombre)'**
  String get optionalUseYourName;

  /// No description provided for @contactPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de Contacto'**
  String get contactPhone;

  /// No description provided for @optionalUseYourPhone.
  ///
  /// In es, this message translates to:
  /// **'Opcional (se usará tu teléfono)'**
  String get optionalUseYourPhone;

  /// No description provided for @noAssociationsAvailableToJoin.
  ///
  /// In es, this message translates to:
  /// **'No hay asociaciones disponibles. Debes crear una nueva.'**
  String get noAssociationsAvailableToJoin;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Registro exitoso. Por favor, verifica tu email.'**
  String get registrationSuccessMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
