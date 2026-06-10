// lib/features/auth/services/Agendamentos_Services/AgendamentoSala/List_Agendamento_Sala_Service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/Agendamentos_salas_endpoints.dart';
import 'package:tcc_yoji/features/auth/models/agendamento_sala_model.dart';

dynamic _parseJson(String responseBody) {
  if (responseBody.isEmpty) return null;
  try {
    return jsonDecode(responseBody);
  } catch (_) {
    return null;
  }
}

Future<List<AgendamentoSala>> carregarAgendamentosSalas(
  String? token, {
  int? salaId,
}) async {
  if (token == null || token.isEmpty) {
    throw Exception('Token não encontrado. Faça login novamente.');
  }

  String urlString = AgendamentoSalaRoutes.listar;
  if (salaId != null) {
    urlString = '$urlString?sala_id=$salaId';
  }

  final response = await http.get(
    Uri.parse(urlString),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  );

  final dados = _parseJson(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      dados?['message'] ?? dados?['error'] ?? 'Erro ao carregar agendamentos.',
    );
  }

  final lista = dados == null
      ? <dynamic>[]
      : dados is List
      ? dados as List<dynamic>
      : (dados['data'] ?? []) as List<dynamic>;

  return lista
      .map((item) => AgendamentoSala.fromJson(item as Map<String, dynamic>))
      .toList();
}
