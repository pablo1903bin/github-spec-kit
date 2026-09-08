/// Fuente única de verdad para los paths de navegación de la app — ningún
/// módulo escribe un literal de ruta a mano, siempre referencia una de estas
/// constantes.
class RoutePath {
  RoutePath._();

  static const login = '/login';
  static const home = '/home';

  /// Ruta con la que arranca la app. Hoy es [login] porque todavía no existe
  /// un flujo de splash/sesión — cuando se agregue, este alias es el único
  /// lugar a actualizar.
  static const inicial = login;
}
