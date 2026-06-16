import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/User_endpoints.dart';
import 'package:tcc_yoji/features/auth/models/auth_response.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';

class LoginService {
  final _secureStorage = SecureStorageService();

  Map<String, dynamic>? _parseJson(http.Response resposta) {
    final text = resposta.body;
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> sendOtp(String email) async {
    if (email.isEmpty) {
      throw Exception('Preencha o email!');
    }

    final resposta = await http.post(
      Uri.parse(UsersRotesServices.sendOtp),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final dados = _parseJson(resposta);

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(dados?['message'] ?? 'Email não encontrado.');
    }
  }

  Future<AuthResponse> loginUser(String email, String otp) async {
    if (email.isEmpty || otp.isEmpty) {
      throw Exception('Preencha o código enviado ao seu email!');
    }

    final resposta = await http.post(
      Uri.parse(UsersRotesServices.login),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': otp, 'platform': 'mobile'}),
    );

    final dados = _parseJson(resposta);

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(dados?['message'] ?? 'Código inválido.');
    }

    if (dados == null) throw Exception('Resposta inválida do servidor.');

    final token = dados['token'] ?? dados['access_token'] ?? '';
    final user = dados['user'] ?? dados['data']?['user'] ?? {};

    final auth = AuthResponse.fromJson({
      ...dados,
      'token': token,
      'user': user,
    });

    await _secureStorage.salvar(auth.token, jsonEncode(auth.user ?? {}));

    return auth;
  }
}
