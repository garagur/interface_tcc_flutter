// lib/features/home/services/turma_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/Turma_endpoints.dart';
import 'package:tcc_yoji/features/auth/models/turma_model.dart';

class TurmaService {
  Map<String, dynamic>? _parseJson(http.Response r) {
    if (r.body.isEmpty) return null;
    try {
      return jsonDecode(r.body);
    } catch (_) {
      return null;
    }
  }

  Future<List<Turma>> carregarTurmas(String token) async {
    if (token.isEmpty)
      throw Exception('Token não encontrado. Faça login novamente.');

    final resp = await http.get(
      Uri.parse(TurmaRoutes.listar),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final dados = _parseJson(resp);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        dados?['message'] ?? dados?['error'] ?? 'Erro ao carregar turmas.',
      );
    }

    final lista = dados == null
        ? <dynamic>[]
        : dados is List
        ? dados as List<dynamic>
        : (dados['turmas'] ?? dados['data'] ?? []) as List<dynamic>;

    return lista.map((s) => Turma.fromJson(s as Map<String, dynamic>)).toList();
  }
}
