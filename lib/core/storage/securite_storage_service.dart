import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyUser = 'user';

  // Salva token e user após login
  Future<void> salvar(String token, String user) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUser, value: user);
  }

  // Lê o token
  Future<String?> lerToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Lê o user
  Future<String?> lerUser() async {
    return await _storage.read(key: _keyUser);
  }

  // Verifica se está logado
  Future<bool> estaLogado() async {
    final token = await lerToken();
    return token != null && token.isNotEmpty;
  }

  // Deleta tudo (logout)
  Future<void> limpar() async {
    await _storage.deleteAll();
  }
}
