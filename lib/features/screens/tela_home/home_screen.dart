// lib/features/screens/tela_home/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';
import 'package:tcc_yoji/features/screens/login/login_screen.dart';
import 'package:tcc_yoji/features/auth/models/agendamento_sala_model.dart';
import 'package:tcc_yoji/features/auth/services/Agendamentos_Services/AgendamentoSala/Show_Agendamento_Sala_Service.dart';
import 'package:tcc_yoji/features/screens/agendamento/tela_agendamento.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = SecureStorageService();

  String _token = '';
  String _email = '';
  List<AgendamentoSala> _agendamentos = [];
  bool _carregando = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await _storage.lerToken();
    final userJson = await _storage.lerUser();

    if (token == null || token.isEmpty) {
      _irParaLogin();
      return;
    }

    String email = '';
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        email = user['email']?.toString() ?? '';
      } catch (_) {}
    }

    setState(() {
      _token = token;
      _email = email;
    });

    await _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = '';
    });
    try {
      final lista = await carregarAgendamentosSalas(_token);
      setState(() => _agendamentos = lista);
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _handleSair() async {
    await _storage.limpar();
    _irParaLogin();
  }

  void _irParaLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ── Helpers de grade ──────────────────────────────────

  Map<String, List<AgendamentoSala>> get _agendamentosPorData {
    final map = <String, List<AgendamentoSala>>{};
    for (final ag in _agendamentos) {
      final chave = ag.dataHoraInicio.length >= 10
          ? ag.dataHoraInicio.substring(0, 10)
          : '';
      if (chave.isEmpty) continue;
      map.putIfAbsent(chave, () => []).add(ag);
    }
    return map;
  }

  List<DateTime> get _dias {
    final hoje = DateTime.now();
    return List.generate(
      60,
      (i) => DateTime(hoje.year, hoje.month, hoje.day + i),
    );
  }

  List<List<DateTime?>> get _semanas {
    final dias = _dias;
    final offset = dias.first.weekday % 7; // 0=Dom
    final cells = <DateTime?>[...List.filled(offset, null), ...dias];
    final semanas = <List<DateTime?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      final semana = cells.sublist(
        i,
        i + 7 > cells.length ? cells.length : i + 7,
      );
      while (semana.length < 7) semana.add(null);
      semanas.add(semana);
    }
    return semanas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafafa),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarAgendamentoScreen()),
          );
          if (resultado == true) _carregarDados();
        },
        backgroundColor: const Color(0xFF4b4b4b),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4b4b4b),
      elevation: 4,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portal de Agendamento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_email.isNotEmpty)
            Text(
              _email,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          tooltip: 'Meus Agendamentos',
          onPressed: () {
            // TODO: navegar para meus agendamentos
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Sair',
          onPressed: _handleSair,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Cabeçalho
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: Color(0xFF4b4b4b)),
                  SizedBox(width: 8),
                  Text(
                    'Agendamentos — 60 dias',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4b4b4b),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFe3f2fd),
                  border: Border.all(color: const Color(0xFFbbdefb)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_agendamentos.length} registros',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c2c2c),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildConteudo()),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4b4b4b)),
      );
    }

    if (_erro.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _erro,
            style: const TextStyle(color: Color(0xFFef4444)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _buildGrade();
  }

  Widget _buildGrade() {
    final hoje = DateTime.now();
    final hojeChave =
        '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
    final porData = _agendamentosPorData;

    const nomesDia = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    const nomesMes = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    // Só mostra dias que têm agendamento OU o dia de hoje
    final dias = _dias.where((dia) {
      final chave =
          '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
      return chave == hojeChave || (porData[chave] ?? []).isNotEmpty;
    }).toList();

    if (dias.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum agendamento nos próximos 60 dias.',
          style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: dias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final dia = dias[i];
        final chave =
            '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
        final isHoje = chave == hojeChave;
        final ags = porData[chave] ?? [];
        final nomeDia = nomesDia[dia.weekday - 1];
        final nomeMes = nomesMes[dia.month];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHoje ? const Color(0xFF4b4b4b) : const Color(0xFFe0e0e0),
              width: isHoje ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do dia
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isHoje
                      ? const Color(0xFF4b4b4b)
                      : const Color(0xFFf1f5f9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isHoje ? Colors.white : const Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomeDia,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isHoje
                                ? Colors.white
                                : const Color(0xFF1e293b),
                          ),
                        ),
                        Text(
                          '$nomeMes de ${dia.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isHoje
                                ? Colors.white70
                                : const Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                    if (isHoje) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Hoje',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Agendamentos do dia
              if (ags.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sem agendamentos',
                    style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                  ),
                )
              else
                ...ags.map((ag) => _AgendamentoTile(ag: ag)),
            ],
          ),
        );
      },
    );
  }
}

class _AgendamentoTile extends StatelessWidget {
  final AgendamentoSala ag;

  const _AgendamentoTile({required this.ag});

  String _hora(String datetime) =>
      datetime.length >= 16 ? datetime.substring(11, 16) : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFf0f7ff),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF1d4ed8), width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.meeting_room, color: Color(0xFF1d4ed8), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sala ${ag.salaId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF64748b),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_hora(ag.dataHoraInicio)} — ${_hora(ag.dataHoraFim)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1d4ed8),
                      ),
                    ),
                  ],
                ),
                if (ag.obs.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    ag.obs,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748b),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Color(0xFF64748b),
              size: 26,
            ),
            onPressed: () {
              // TODO: detalhes
            },
          ),
        ],
      ),
    );
  }
}
