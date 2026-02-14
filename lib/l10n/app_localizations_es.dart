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
  String get noAssociationAvailable => 'No hay asociación disponible';

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

  @override
  String get usersListTitle => 'Listado de usuarios';

  @override
  String get editUser => 'Editar Usuario';

  @override
  String get verifyEmailTitle => 'Verificar Correo';

  @override
  String get verifyEmailHeadline => 'Verifica tu correo electrónico';

  @override
  String verifyEmailInstruction(Object email) {
    return 'Hemos enviado un correo de verificación a $email. Por favor, revisa tu bandeja de entrada y sigue las instrucciones para activar tu cuenta.';
  }

  @override
  String get resendEmail => 'Reenviar correo';

  @override
  String get verificationEmailSent => 'Correo de verificación reenviado.';

  @override
  String errorResendingEmail(Object error) {
    return 'Error al reenviar el correo: $error';
  }

  @override
  String get status => 'Estado';

  @override
  String get memberships => 'Membresías';

  @override
  String get userHasNoMemberships =>
      'Este usuario no pertenece a ninguna asociación.';

  @override
  String get roleTitle => 'Rol';

  @override
  String get addMembership => 'Añadir Membresía';

  @override
  String get addMembershipDialogTitle => 'Añadir Membresía';

  @override
  String get selectAssociation => 'Seleccionar asociación';

  @override
  String get add => 'Añadir';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get never => 'Nunca';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get morningAndAfternoon => 'Mañana y Tarde';

  @override
  String get deleteUser => 'Borrar Usuario';

  @override
  String deleteUserConfirmation(String userName) {
    return '¿Estás seguro de que quieres borrar a $userName? Esta acción es irreversible.';
  }

  @override
  String get createUser => 'Crear Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get editMode => 'Modo Edición';

  @override
  String get all => 'Todas';

  @override
  String get createArticle => 'Crear Artículo';

  @override
  String get editArticle => 'Editar Artículo';

  @override
  String get title => 'Título';

  @override
  String get abstractContent => 'Resumen';

  @override
  String get category => 'Categoría';

  @override
  String get subcategory => 'Subcategoría';

  @override
  String get sections => 'Secciones';

  @override
  String get publishDateLabel => 'Fecha de Publicación';

  @override
  String get effectiveDateLabel => 'Fecha de Efecto';

  @override
  String get expirationDateLabel => 'Fecha de Expiración (opcional)';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String get selectCoverImage => 'Seleccionar imagen de portada';

  @override
  String get articles => 'Artículos';

  @override
  String get deleteArticle => 'Borrar Artículo';

  @override
  String get articleTitle => 'Título del Artículo';

  @override
  String get articleAbstract => 'Resumen del Artículo';

  @override
  String get coverImage => 'Imagen de Portada';

  @override
  String get articleStatus => 'Estado';

  @override
  String get addSection => 'Añadir Sección';

  @override
  String get removeSection => 'Eliminar Sección';

  @override
  String get reorderSections => 'Reordenar Secciones';

  @override
  String get statusRedaccion => 'En Redacción';

  @override
  String get statusPublicado => 'Publicado';

  @override
  String get statusRevision => 'En Revisión';

  @override
  String get statusExpirado => 'Expirado';

  @override
  String get statusAnulado => 'Anulado';

  @override
  String get statusNotificar => 'Publicar y Notificar';

  @override
  String get statusNotificarShort => 'Notificar';

  @override
  String get notificationFreqNone => 'No recibir notificaciones';

  @override
  String get notificationFreqOnce => 'Una vez al día (12:00)';

  @override
  String get notificationFreqTwice => 'Dos veces (10:00 y 20:00)';

  @override
  String get notificationFreqThrice => 'Tres veces (10:00, 15:00, 20:00)';

  @override
  String get categoryInformacion => 'Información';

  @override
  String get categoryNoticias => 'Noticias';

  @override
  String get categoryActas => 'Actas';

  @override
  String get subcategoryServicios => 'Servicios';

  @override
  String get subcategoryCultura => 'Cultura';

  @override
  String get subcategoryReuniones => 'Reuniones';

  @override
  String get subcategoryAsambleas => 'Asambleas';

  @override
  String get subcategoryMunicipio => 'Municipio';

  @override
  String get subcategoryUrbanizacion => 'Urbanización';

  @override
  String get searchArticles => 'Buscar artículos...';

  @override
  String get filterByCategory => 'Filtrar por categoría';

  @override
  String get articleCreatedSuccess => 'Artículo creado correctamente.';

  @override
  String get articleUpdatedSuccess => 'Artículo actualizado correctamente.';

  @override
  String get articleDeletedSuccess => 'Artículo eliminado correctamente.';

  @override
  String get titleRequired => 'El título es obligatorio.';

  @override
  String get abstractRequired => 'El resumen es obligatorio.';

  @override
  String get coverRequired => 'La imagen de portada es obligatoria.';

  @override
  String get categoryRequired => 'La categoría es obligatoria.';

  @override
  String get subcategoryRequired => 'La subcategoría es obligatoria.';

  @override
  String get publicationDateRequired =>
      'La fecha de publicación es obligatoria.';

  @override
  String get effectiveDateRequired => 'La fecha de vigencia es obligatoria.';

  @override
  String get publicationDateInvalid =>
      'La fecha de publicación debe ser hoy o posterior.';

  @override
  String get effectiveDateInvalid =>
      'La fecha de vigencia debe ser igual o posterior a la de publicación.';

  @override
  String get expirationDateInvalid =>
      'La fecha de caducidad debe ser igual o posterior a la de publicación.';

  @override
  String get sectionContentRequired =>
      'Cada sección debe tener contenido o una imagen.';

  @override
  String get readMode => 'Modo Lectura';

  @override
  String get section => 'Sección';

  @override
  String get titleCharLimitExceeded =>
      'El título no puede exceder los 100 caracteres.';

  @override
  String get abstractCharLimitExceeded =>
      'El resumen no puede exceder los 200 caracteres.';

  @override
  String get removeSectionConfirmation =>
      '¿Estás seguro de que quieres eliminar esta sección? Esta acción no se puede deshacer.';

  @override
  String get previewMode => 'Previsualizar';

  @override
  String get edit => 'Editar';

  @override
  String get draftFoundTitle => 'Borrador encontrado';

  @override
  String get draftFoundMessage =>
      'Hemos encontrado un borrador sin guardar. ¿Deseas restaurarlo?';

  @override
  String get discard => 'Descartar';

  @override
  String get restore => 'Restaurar';

  @override
  String get configuration => 'Configuración';

  @override
  String get start => 'a partir de';

  @override
  String get toThe => 'al';

  @override
  String get from => 'del';

  @override
  String get effectivePublishDate => 'Fecha vigencia publicación';

  @override
  String get personalData => 'Datos Personales';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordMinLength => 'Mínimo 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar Contraseña *';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get createNewAssociation => 'Crear nueva asociación';

  @override
  String get youWillBeAdmin => 'Serás administrador de la asociación';

  @override
  String get createGeneralAssociation =>
      'Crear Asociación General (SuperAdmin)';

  @override
  String get newAssociationData => 'Datos de la Nueva Asociación';

  @override
  String get shortNameHint => 'Ej: ASOC2024';

  @override
  String get longNameHint => 'Ej: Asociación de Vecinos 2024';

  @override
  String get contactEmail => 'Email de Contacto';

  @override
  String get optionalUseYourEmail => 'Opcional (se usará tu email)';

  @override
  String get optionalUseYourName => 'Opcional (se usará tu nombre)';

  @override
  String get contactPhone => 'Teléfono de Contacto';

  @override
  String get optionalUseYourPhone => 'Opcional (se usará tu teléfono)';

  @override
  String get noAssociationsAvailableToJoin =>
      'No hay asociaciones disponibles. Debes crear una nueva.';

  @override
  String get register => 'Registrarse';

  @override
  String get registrationSuccessMessage =>
      'Registro exitoso. Por favor, verifica tu correo electrónico.';

  @override
  String get genericError => 'Hubo un problema al cargar los datos.';

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get unsavedChangesMessage =>
      'Tienes cambios sin guardar. ¿Deseas salir sin guardarlos?';

  @override
  String get stay => 'Quedarse';

  @override
  String get leaveWithoutSaving => 'Salir sin guardar';
}
