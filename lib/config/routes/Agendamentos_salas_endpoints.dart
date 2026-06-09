import 'package:tcc_yoji/core/contants/api_constants.dart';

class AgendamentoSalaRoutes {
  static const String listar = '${ApiConstants.apiUrl}/agendamento-salas';
  static const String cadastrar = '${ApiConstants.apiUrl}/agendamento-salas';
  static String buscar(int id) =>
      '${ApiConstants.apiUrl}/agendamento-salas/$id';
  static String deletar(int id) =>
      '${ApiConstants.apiUrl}/agendamento-salas/$id';
}
