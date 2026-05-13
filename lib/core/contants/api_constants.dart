class ApiConstants {
  // URL base
  static const String apiUrl = 'http://localhost:8000/api/eafinware';

  // Rotas de autenticação
  static const String login = '$apiUrl/auth/login';
  static const String logout = '$apiUrl/auth/logout';
  static const String me = '$apiUrl/auth/me';

  // Rotas dinâmicas (com ID)
  static String buscarUsuario(int id) => '$apiUrl/users/$id';
  static String deletarUsuario(int id) => '$apiUrl/users/$id';
}
