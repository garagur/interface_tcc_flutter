import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/Agendamentos_salas_endpoints.dart';

dynamic _parseJson(String responseBody) {
  if (responseBody.isEmpty) return null;
  try {
    return jsonDecode(responseBody);
  } catch (_) {
    return null;
  }
}

Future<void> deletarAgendamentoSala(int id, String? token) async {
  if (token == null || token.isEmpty) {
    throw Exception('Token não encontrado. Faça login novamente.');
  }

  final response = await http.delete(
    Uri.parse(AgendamentoSalaRoutes.deletar(id)),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final dados = _parseJson(response.body);
    throw Exception(dados?['message'] ?? 'Erro ao deletar agendamento.');
  }
}
