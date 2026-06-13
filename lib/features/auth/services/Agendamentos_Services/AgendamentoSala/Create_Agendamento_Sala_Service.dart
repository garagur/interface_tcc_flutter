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

/// Função principal para cadastrar o agendamento
Future<dynamic> cadastrarAgendamento(
  AgendamentoSala novoAgendamentoSala,
  String? token,
) async {
  if (token == null || token.isEmpty) {
    throw Exception(
      'Token de autenticação não encontrado. Faça login novamente.',
    );
  }

  final url = Uri.parse(AgendamentoSalaRoutes.cadastrar);

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(novoAgendamentoSala.toJson()),
  );

  final dados = _parseJson(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    if (dados != null && dados['errors'] != null) {
      final Map<String, dynamic> errors = dados['errors'];
      final dynamic errorMessages = errors.values
          .expand((element) {
            return element is List ? element : [element];
          })
          .join(' ');

      throw Exception(errorMessages);
    }

    final errorMessage =
        dados?['message'] ?? dados?['error'] ?? 'Erro ao agendar sala.';
    throw Exception(errorMessage);
  }

  return dados?['data'] ?? dados ?? {};
}
