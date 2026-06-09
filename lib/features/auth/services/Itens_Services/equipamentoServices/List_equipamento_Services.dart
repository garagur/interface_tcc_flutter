import 'package:dio/dio.dart';
import 'package:tcc_yoji/config/routes/Equipamentos_endpoints.dart';

class EquipamentoService {
  final Dio _dio;

  EquipamentoService(this._dio);

  Future<List<Map<String, dynamic>>> carregarEquipamentos(String token) async {
    if (token.isEmpty) {
      throw Exception(
        'Token de autenticação não encontrado. Faça login novamente.',
      );
    }

    final response = await _dio.get(
      ItensRotesServices.listarEquipamentos,
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
          (e) => {
            'id': e['id'],
            'nome': e['nome'] ?? '',
            'N_patrimonio': e['N_patrimonio'] ?? '',
            'obs': e['obs'] ?? '',
            'status': e['status'] ?? true,
          },
        )
        .toList();
  }
}
