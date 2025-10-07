// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ConectAsoc';

  @override
  String get homePage => 'Inicio';

  @override
  String get noArticlesYet => 'No hay artículos por ahora.';

  @override
  String get changeAssociation => 'Cambiar de Asociación';

  @override
  String get unknownAssociation => 'Asociación desconocida';

  @override
  String role(Object roleName) {
    return 'Rol: $roleName';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String errorLoadingAssociations(Object error) {
    return 'Error al cargar las asociaciones: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get registrationError => 'Error en el Registro';

  @override
  String get accept => 'Aceptar';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado.';

  @override
  String get leaveAssociation => 'Abandonar Asociación';

  @override
  String get leave => 'Abandonar';

  @override
  String get leaveAssociationConfirmationTitle => 'Confirmar abandono';

  @override
  String leaveAssociationConfirmationMessage(Object associationName) {
    return '¿Estás seguro de que quieres abandonar la asociación \'$associationName\'? Esta acción no se puede deshacer.';
  }

  @override
  String get users => 'Usuarios';

  @override
  String get associations => 'Asociaciones';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get joinAssociation => 'Unirse a Asociación';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get login => 'Acceder';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get profileSavedSuccess => 'Perfil guardado con éxito';

  @override
  String get profileLoadError => 'Error al cargar el perfil.';

  @override
  String get name => 'Nombre';

  @override
  String get lastname => 'Apellidos';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Teléfono';

  @override
  String get language => 'Idioma';

  @override
  String get langSpanish => 'Español';

  @override
  String get langEnglish => 'English';

  @override
  String get langCatalan => 'Català';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get cropImage => 'Recortar Imagen';

  @override
  String get association => 'Asociación';

  @override
  String get search => 'Buscar...';

  @override
  String get contact => 'Contacto';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get associationsListTitle => 'Listado de asociaciones';
}
