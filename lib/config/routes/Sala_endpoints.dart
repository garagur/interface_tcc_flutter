import 'package:tcc_yoji/core/contants/api_constants.dart';

class SalaEndPoints {
  static const String listarSalas = '${ApiConstants.apiUrl}/salas';
  static String buscarSala(int id) => '${ApiConstants.apiUrl}/salas/$id';
}
