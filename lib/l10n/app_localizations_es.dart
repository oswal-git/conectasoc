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

  @override
  String get changesSavedSuccessfully => 'Cambios guardados con éxito';

  @override
  String get shortName => 'Nombre corto';

  @override
  String get longName => 'Nombre largo';

  @override
  String get contactName => 'Nombre de contacto';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get associationIdCannotBeEmpty =>
      'El ID de la asociación no puede estar vacío.';

  @override
  String get shortAndLongNameRequired =>
      'El nombre corto y el nombre largo son obligatorios.';

  @override
  String get invalidEmailFormat => 'El formato del email no es válido.';

  @override
  String get errorUploadingLogo => 'Error al subir el logo';

  @override
  String unexpectedErrorOcurred(Object error) {
    return 'Ocurrió un error inesperado: $error';
  }

  @override
  String get incompleteAssociationData =>
      'Los datos de la nueva asociación están incompletos.';

  @override
  String get mustSelectAnAssociation =>
      'Debe seleccionar una asociación para unirse.';

  @override
  String get welcomeSubtitle => 'Portal de Asociaciones';

  @override
  String get welcomeReadOnlyTitle => 'Solo Lectura';

  @override
  String get welcomeReadOnlyDescription => 'Explora contenido sin registro';

  @override
  String get welcomeLoginTitle => 'Iniciar Sesión';

  @override
  String get welcomeLoginDescription => 'Ya tengo una cuenta';

  @override
  String get welcomeRegisterDescription =>
      'Registro completo con notificaciones';

  @override
  String get exitReadOnlyMode => 'Salir del modo lectura';

  @override
  String get createAssociation => 'Crear Asociación';

  @override
  String get deleteAssociation => 'Borrar Asociación';

  @override
  String deleteAssociationConfirmation(Object associationName) {
    return '¿Estás seguro de que quieres borrar la asociación \'$associationName\'? Esta acción no se puede deshacer.';
  }

  @override
  String get associationHasUsersError =>
      'No se puede borrar la asociación porque tiene usuarios asignados.';

  @override
  String get associationDeletedSuccessfully => 'Asociación borrada con éxito.';

  @override
  String get delete => 'Borrar';

  @override
  String get undo => 'Deshacer';

  @override
  String get contactPerson => 'Persona de contacto';
}
