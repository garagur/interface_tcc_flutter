import 'package:http/http.dart' as http;
import 'package:tcc_yoji/config/routes/User_endpoints.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';

class LogoutService {
  final _secureStorage = SecureStorageService();

  Future<void> logoutUser() async {
    final token = await _secureStorage.lerToken();

    // Se não tem token nem precisa chamar a API
    if (token == null || token.isEmpty) {
      await _secureStorage.limpar();
      return;
    }

    try {
      await http.post(
        Uri.parse(UsersRotesServices.logout),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao deslogar: $e');
    } finally {
      // Limpa o storage independente de sucesso ou falha na API
      await _secureStorage.limpar();
    }
  }
}
