import 'package:tcc_yoji/core/contants/api_constants.dart';

class UsersRotesServices {
  static const String login = '${ApiConstants.apiUrl}/auth/login';
  static const String logout = '${ApiConstants.apiUrl}/auth/logout';
  static const String me = '${ApiConstants.apiUrl}/auth/me';
  static const String sendOtp = '${ApiConstants.apiUrl}/auth/send-otp';
  static String buscarUsuario(int id) => '${ApiConstants.apiUrl}/users/$id';
  static String deletarUsuario(int id) => '${ApiConstants.apiUrl}/users/$id';
}
