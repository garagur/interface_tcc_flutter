import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/core/contants/api_constants.dart';
import 'package:tcc_yoji/features/auth/models/auth_response.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';

class LoginService {
  final _secureStorage = SecureStorageService();

  Future<AuthResponse> loginUser(String matricula, String senha) async {
    if (matricula.isEmpty || senha.isEmpty) {
      throw Exception('Preencha a matrícula e a senha!');
    }

    final resposta = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'matricula': matricula, 'password': senha}),
    );

    final text = resposta.body;
    if (text.isEmpty) throw Exception('Resposta vazia do servidor.');

    Map<String, dynamic> dados;
    try {
      dados = jsonDecode(text);
    } catch (_) {
      throw Exception('Resposta inválida do servidor.');
    }

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        dados['message'] ?? dados['error'] ?? 'Credenciais inválidas.',
      );
    }

    final auth = AuthResponse.fromJson(dados);

    // Salva no SecureStorage após login bem-sucedido
    await _secureStorage.salvar(auth.token, jsonEncode(auth.user ?? {}));

    return auth;
  }
}
