import 'package:tcc_yoji/core/contants/api_constants.dart';

class TurmaRoutes {
  static const String listar = '${ApiConstants.apiUrl}/turmas';
  static String buscar(int id) => '${ApiConstants.apiUrl}/turmas/$id';
  static const String cadastrar = '${ApiConstants.apiUrl}/turmas';
  static String atualizar(int id) => '${ApiConstants.apiUrl}/turmas/$id';
  static String deletar(int id) => '${ApiConstants.apiUrl}/turmas/$id';
}
