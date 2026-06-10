import 'package:flutter/material.dart';
import 'package:tcc_yoji/features/auth/services/User_Services/login_service.dart';
import 'package:tcc_yoji/features/screens/tela_home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final void Function(dynamic data)? onLogin;

  const LoginScreen({super.key, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _loginService = LoginService();

  // Controla em qual etapa estamos
  bool _otpEnviado = false;
  String _erro = '';
  bool _carregando = false;

  // Etapa 1 — envia OTP
  Future<void> _handleSendOtp() async {
    setState(() {
      _erro = '';
      _carregando = true;
    });

    try {
      await _loginService.sendOtp(_emailController.text.trim());
      setState(() => _otpEnviado = true);
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // Etapa 2 — valida OTP e loga
  Future<void> _handleLogin() async {
    setState(() {
      _erro = '';
      _carregando = true;
    });

    try {
      final data = await _loginService.loginUser(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );

      widget.onLogin?.call(data);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // Volta para a etapa do email
  void _voltarParaEmail() {
    setState(() {
      _otpEnviado = false;
      _otpController.clear();
      _erro = '';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0ea5e9), Color(0xFF172554)],
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
                  const Text(
                    'Acesso ao Sistema',
                    style: TextStyle(
                      color: Color(0xFF0284c7),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Etapa 1: email
                  if (!_otpEnviado) ...[
                    _campo(
                      label: 'Email',
                      placeholder: 'seu@email.com',
                      controller: _emailController,
                      obscure: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],

                  // Etapa 2: OTP
                  if (_otpEnviado) ...[
                    Text(
                      'Código enviado para\n${_emailController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _campo(
                      label: 'Código OTP',
                      placeholder: '000000',
                      controller: _otpController,
                      obscure: false,
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Erro
                  if (_erro.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _erro,
                        style: const TextStyle(
                          color: Color(0xFFdc2626),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Botão principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _carregando
                          ? null
                          : (_otpEnviado ? _handleLogin : _handleSendOtp),
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
                        _carregando
                            ? (_otpEnviado ? 'Entrando...' : 'Enviando...')
                            : (_otpEnviado ? 'Entrar' : 'Enviar código'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Voltar (só na etapa do OTP)
                  if (_otpEnviado) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _carregando ? null : _voltarParaEmail,
                      child: const Text(
                        'Usar outro email',
                        style: TextStyle(
                          color: Color(0xFF0284c7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool obscure,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
