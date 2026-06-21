// lib/features/agendamentos/screens/meus_agendamentos_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';
import 'package:tcc_yoji/features/auth/models/agendamento_sala_model.dart';
import 'package:tcc_yoji/features/auth/services/Agendamentos_Services/AgendamentoSala/List_Agendamento_Sala_Service.dart';
import 'package:tcc_yoji/features/auth/services/Agendamentos_Services/AgendamentoSala/Deleted_Agendamento_Sala_Service.dart';

class MeusAgendamentosScreen extends StatefulWidget {
  const MeusAgendamentosScreen({super.key});

  @override
  State<MeusAgendamentosScreen> createState() => _MeusAgendamentosScreenState();
}

class _MeusAgendamentosScreenState extends State<MeusAgendamentosScreen> {
  final _secureStorage = SecureStorageService();

  String? _token;
  String? _userId;

  List<AgendamentoSala> _agendamentos = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final token = await _secureStorage.lerToken();
    final userJson = await _secureStorage.lerUser();

    if (token == null || token.isEmpty) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    String? userId;
    if (userJson != null && userJson.isNotEmpty) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      userId = user['id']?.toString();
    }

    setState(() {
      _token = token;
      _userId = userId;
    });

    await _carregarMeusAgendamentos();
  }

  Future<void> _carregarMeusAgendamentos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final todos = await carregarAgendamentosSalas(_token);
      final meus = todos
          .where((ag) => ag.userId?.toString() == _userId)
          .toList();
      setState(() {
        _agendamentos = meus;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _confirmarDeletar(AgendamentoSala ag) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza que deseja deletar esse agendamento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await deletarAgendamentoSala(ag.id!, _token);
      setState(() {
        _agendamentos.removeWhere((a) => a.id == ag.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  // Ordena: futuros primeiro, depois por data (equivalente ao $: agendamentosOrdenados)
  List<AgendamentoSala> get _agendamentosOrdenados {
    final lista = [..._agendamentos];
    lista.sort((a, b) {
      final fa = a.isFuturo;
      final fb = b.isFuturo;
      if (fa != fb) return fb ? 1 : -1;
      final da = DateTime.tryParse(a.dataHoraInicio) ?? DateTime(0);
      final db = DateTime.tryParse(b.dataHoraInicio) ?? DateTime(0);
      return da.compareTo(db);
    });
    return lista;
  }

  String _formatarDataHora(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return '—';
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data às $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4b4b4b),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal de Agendamento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Meus Agendamentos',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _carregarMeusAgendamentos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_erro != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _erro!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                  ),
                ),
              ),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.event_available, color: Color(0xFF1F2937)),
                        SizedBox(width: 10),
                        Text(
                          'Meus Agendamentos de Sala',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    if (_carregando)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_agendamentosOrdenados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Nenhum agendamento de sala encontrado.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _agendamentosOrdenados
                            .map(
                              (ag) => _AgendamentoItem(
                                agendamento: ag,
                                formatarDataHora: _formatarDataHora,
                                onDeletar: ag.isFuturo
                                    ? () => _confirmarDeletar(ag)
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendamentoItem extends StatelessWidget {
  final AgendamentoSala agendamento;
  final String Function(String?) formatarDataHora;
  final VoidCallback? onDeletar;

  const _AgendamentoItem({
    required this.agendamento,
    required this.formatarDataHora,
    this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    final futuro = agendamento.isFuturo;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: const Color(0xFF4b4b4b)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF1F2937),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${formatarDataHora(agendamento.dataHoraInicio)}  →  ${formatarDataHora(agendamento.dataHoraFim)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room,
                          size: 15,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          agendamento.salaNome.isNotEmpty
                              ? agendamento.salaNome
                              : 'Sala não informada',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    if (agendamento.obs.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        agendamento.obs,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: futuro
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      futuro ? 'AGENDADO' : 'CONCLUÍDO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: futuro
                            ? const Color(0xFF16A34A)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (onDeletar != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: onDeletar,
                      tooltip: 'Deletar agendamento',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
