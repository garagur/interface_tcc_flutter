import 'package:dio/dio.dart';
import 'package:tcc_yoji/config/routes/Sala_endpoints.dart';

class SalaService {
  final Dio _dio;

  SalaService(this._dio);

  Future<List<Map<String, dynamic>>> carregarSalas(String token) async {
    if (token.isEmpty) {
      throw Exception(
        'Token de autenticação não encontrado. Faça login novamente.',
      );
    }

    final response = await _dio.get(
      SalaEndPoints.listarSalas,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final dados = response.data;

    final List lista = dados is List ? dados : (dados?['data'] ?? []);

    return lista
        .map<Map<String, dynamic>>(
          (s) => {
            'id': s['id'],
            'nome': s['nome'] ?? '',
            'numero': s['numero'] ?? '',
            'obs': s['obs'] ?? '',
            'status': s['status'] ?? true,
          },
        )
        .toList();
  }
}
