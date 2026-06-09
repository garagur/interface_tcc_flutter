import 'package:tcc_yoji/core/contants/api_constants.dart';

class HorarioRoutes {
  static const String listar = '${ApiConstants.apiUrl}/blocos-horario';
  static const String cadastrar = '${ApiConstants.apiUrl}/blocos-horario';
  static String buscar(int id) => '${ApiConstants.apiUrl}/blocos-horario/$id';
  static String atualizar(int id) =>
      '${ApiConstants.apiUrl}/blocos-horario/$id';
  static String deletar(int id) => '${ApiConstants.apiUrl}/blocos-horario/$id';
}
