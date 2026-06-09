// lib/features/auth/services/Horario_Services/list_horarios_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/Horario_endpoints.dart';

class Horario {
  final int id;
  final dynamic turmaId;
  final String turmaNome;
  final dynamic salaId;
  final String salaNome;
  final dynamic professorId;
  final String diaSemana;
  final String disciplina;
  final String horaInicio;
  final String horaFim;

  Horario({
    required this.id,
    required this.turmaId,
    required this.turmaNome,
    required this.salaId,
    required this.salaNome,
    required this.professorId,
    required this.diaSemana,
    required this.disciplina,
    required this.horaInicio,
    required this.horaFim,
  });

  factory Horario.fromJson(Map<String, dynamic> j) => Horario(
    id: j['id'],
    turmaId: j['turma']?['id'] ?? j['turma_id'] ?? '',
    turmaNome: j['turma']?['nome'] ?? '',
    salaId: j['sala']?['id'] ?? j['sala_id'] ?? '',
    salaNome: j['sala']?['nome'] ?? '',
    professorId: j['professor']?['id'] ?? j['professor_id'] ?? '',
    diaSemana: j['dia_semana'] ?? '',
    disciplina: j['disciplina'] ?? '',
    horaInicio: j['hora_inicio'] ?? '',
    horaFim: j['hora_fim'] ?? '',
  );
}

class ListHorariosService {
  Map<String, dynamic>? _parseJson(http.Response r) {
    if (r.body.isEmpty) return null;
    try {
      return jsonDecode(r.body);
    } catch (_) {
      return null;
    }
  }

  Future<List<Horario>> carregarHorarios(String token, {int? turmaId}) async {
    if (token.isEmpty) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final url = turmaId != null
        ? '${HorarioRoutes.listar}?turma_id=$turmaId'
        : HorarioRoutes.listar;

    final resp = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final dados = _parseJson(resp);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        dados?['message'] ?? dados?['error'] ?? 'Erro ao carregar horários.',
      );
    }

    final lista = dados == null
        ? <dynamic>[]
        : dados is List
        ? dados as List<dynamic>
        : (dados['blocos'] ?? dados['data'] ?? []) as List<dynamic>;

    return lista
        .map((s) => Horario.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Horario>> carregarHorariosProfessor(
    String token,
    dynamic professorId,
  ) async {
    if (token.isEmpty) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final resp = await http.get(
      Uri.parse('${HorarioRoutes.listar}?professor_id=$professorId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final dados = _parseJson(resp);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        dados?['message'] ?? dados?['error'] ?? 'Erro ao carregar horários.',
      );
    }

    final raw = dados is List
        ? dados as List<dynamic>
        : (dados?['blocos'] ?? dados?['data'] ?? []) as List<dynamic>;

    return raw.map((s) => Horario.fromJson(s as Map<String, dynamic>)).toList();
  }
}
