import 'package:flutter/material.dart';
import 'package:tcc_yoji/features/auth/services/login_service.dart';
import 'package:tcc_yoji/features/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(dynamic data)? onLogin;

  const LoginScreen({super.key, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matriculaController = TextEditingController();
  final _senhaController = TextEditingController();
  final _loginService = LoginService();

  String _erroLogin = '';
  bool _carregando = false;

  // Equivalente ao handleSubmit do Svelte
  Future<void> _handleSubmit() async {
    setState(() {
      _erroLogin = '';
      _carregando = true;
    });

    try {
      final data = await _loginService.loginUser(
        _matriculaController.text,
        _senhaController.text,
      );

      widget.onLogin?.call(data);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              matricula: data.user?['matricula']?.toString() ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _erroLogin = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Equivalente ao linear-gradient do CSS
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0ea5e9), // #0ea5e9
              Color(0xFF172554), // #172554
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  const Text(
                    'Acesso ao Sistema',
                    style: TextStyle(
                      color: Color(0xFF0284c7),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo matrícula
                  _campo(
                    label: 'Matrícula',
                    placeholder: '000000',
                    controller: _matriculaController,
                    obscure: false,
                  ),
                  const SizedBox(height: 16),

                  // Campo senha
                  _campo(
                    label: 'Senha',
                    placeholder: '******',
                    controller: _senhaController,
                    obscure: true,
                  ),
                  const SizedBox(height: 8),

                  // Mensagem de erro
                  if (_erroLogin.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _erroLogin,
                        style: const TextStyle(
                          color: Color(0xFFdc2626),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Botão entrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284c7),
                        disabledBackgroundColor: const Color(
                          0xFF0284c7,
                        ).withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _carregando ? 'Entrando...' : 'Entrar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper para os campos — evita repetição
  Widget _campo({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool obscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF64748b),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFcbd5e1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFcbd5e1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF38bdf8)),
            ),
          ),
        ),
      ],
    );
  }
}
