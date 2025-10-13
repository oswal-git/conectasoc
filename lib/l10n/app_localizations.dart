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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
