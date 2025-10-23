/// Interfaz base para cualquier tipo de usuario en la aplicación.
/// Define las propiedades y métodos comunes necesarios para la lógica de negocio,
/// como la gestión de permisos y la obtención de identificadores de asociación.
abstract class IUser {
  /// Lista de IDs de las asociaciones a las que pertenece el usuario.
  List<String> get associationIds;

  /// Indica si el usuario tiene permisos para editar contenido (superadmin, admin, editor).
  bool get canEditContent;

  /// Indica si el usuario es un superadministrador global.
  bool get isSuperAdmin;
}
