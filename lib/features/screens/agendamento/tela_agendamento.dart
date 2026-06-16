//
import 'package:flutter/material.dart';
import 'package:tcc_yoji/core/storage/securite_storage_service.dart';
import 'package:tcc_yoji/features/auth/models/agendamento_sala_model.dart';
import 'package:tcc_yoji/features/auth/models/Horario_model.dart';
import 'package:tcc_yoji/features/auth/services/Agendamentos_Services/AgendamentoSala/Show_Agendamento_Sala_Service.dart';
import 'package:tcc_yoji/features/auth/services/Agendamentos_Services/AgendamentoSala/Create_Agendamento_Sala_Service.dart';
import 'package:tcc_yoji/features/auth/services/Horario_Services/List_horarios_service.dart';
import 'package:tcc_yoji/features/auth/services/Itens_Services/salaServices/List_Sala_Services.dart';
import 'package:dio/dio.dart';

// ── Model local de Sala (se ainda não tiver separado) ──
class Sala {
  final int id;
  final String nome;
  final String numero;

  Sala({required this.id, required this.nome, required this.numero});

  factory Sala.fromJson(Map<String, dynamic> j) => Sala(
    id: j['id'],
    nome: j['nome'] ?? '',
    numero: j['numero']?.toString() ?? '',
  );
}

class CriarAgendamentoScreen extends StatefulWidget {
  const CriarAgendamentoScreen({super.key});

  @override
  State<CriarAgendamentoScreen> createState() => _CriarAgendamentoScreenState();
}

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  final _salaService = SalaService(Dio());
  final _storage = SecureStorageService();
  final _horariosService = ListHorariosService();
  final _obsController = TextEditingController();

  String _token = '';

  // Seleções
  Sala? _salaSelecionada;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  // Dados carregados
  List<Sala> _salas = [];
  List<Horario> _horariosSala = [];
  List<AgendamentoSala> _agendamentosSala = [];

  // Estados
  bool _carregandoSalas = false;
  bool _carregandoHorarios = false;
  bool _salvando = false;
  String _erro = '';

  // Dias da semana em português (weekday 1=Seg ... 7=Dom)
  static const _nomesDia = [
    '',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  static const _diasSemana = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await _storage.lerToken();
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() => _token = token);
    await _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    setState(() => _carregandoSalas = true);
    try {
      final lista = await _salaService.carregarSalas(_token);
      setState(
        () => _salas = lista
            .map(
              (s) => Sala(
                id: s['id'],
                nome: s['nome'] ?? '',
                numero: s['numero']?.toString() ?? '',
              ),
            )
            .toList(),
      );
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregandoSalas = false);
    }
  }

  Future<void> _carregarDadosSala(int salaId) async {
    setState(() {
      _carregandoHorarios = true;
      _horariosSala = [];
      _agendamentosSala = [];
    });
    try {
      final resultados = await Future.wait([
        _horariosService.carregarHorarios(_token),
        carregarAgendamentosSalas(_token, salaId: salaId),
      ]);
      setState(() {
        _horariosSala = (resultados[0] as List<Horario>)
            .where((h) => h.salaId.toString() == salaId.toString())
            .toList();
        _agendamentosSala = resultados[1] as List<AgendamentoSala>;
      });
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _carregandoHorarios = false);
    }
  }

  void _abrirSeletorSala() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, controller) => Column(
          children: [
            // Alça
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFcbd5e1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Selecionar Sala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
            ),
            const Divider(),
            _carregandoSalas
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _salas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final sala = _salas[i];
                        final selecionada = _salaSelecionada?.id == sala.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _salaSelecionada = sala);
                            Navigator.pop(context);
                            _carregarDadosSala(sala.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selecionada
                                  ? const Color(0xFFdbeafe)
                                  : const Color(0xFFf8fafc),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selecionada
                                    ? const Color(0xFF1d4ed8)
                                    : const Color(0xFFe2e8f0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selecionada
                                        ? const Color(0xFF1d4ed8)
                                        : const Color(0xFFe2e8f0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.meeting_room,
                                    color: selecionada
                                        ? Colors.white
                                        : const Color(0xFF64748b),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sala.nome,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: selecionada
                                            ? const Color(0xFF1d4ed8)
                                            : const Color(0xFF1e293b),
                                      ),
                                    ),
                                    if (sala.numero.isNotEmpty)
                                      Text(
                                        'Número: ${sala.numero}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748b),
                                        ),
                                      ),
                                  ],
                                ),
                                if (selecionada) ...[
                                  const Spacer(),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1d4ed8),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year, hoje.month, hoje.day),
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year, hoje.month, hoje.day + 60),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora({required bool isInicio}) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = hora;
        } else {
          _horaFim = hora;
        }
      });
    }
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatarHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _horaParaDatetime(DateTime data, TimeOfDay hora) =>
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')} ${_formatarHora(hora)}:00';

  String _extrairHora(String datetime) =>
      datetime.length >= 16 ? datetime.substring(11, 16) : '';

  String _extrairData(String datetime) {
    if (datetime.length < 10) return '';
    final p = datetime.substring(0, 10).split('-');
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  Future<void> _salvar() async {
    if (_salaSelecionada == null) {
      setState(() => _erro = 'Selecione uma sala.');
      return;
    }
    if (_dataSelecionada == null) {
      setState(() => _erro = 'Selecione uma data.');
      return;
    }
    if (_horaInicio == null) {
      setState(() => _erro = 'Selecione a hora de início.');
      return;
    }
    if (_horaFim == null) {
      setState(() => _erro = 'Selecione a hora de fim.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = '';
    });

    try {
      final novo = AgendamentoSala(
        salaId: _salaSelecionada!.id,
        dataHoraInicio: _horaParaDatetime(_dataSelecionada!, _horaInicio!),
        dataHoraFim: _horaParaDatetime(_dataSelecionada!, _horaFim!),
        obs: _obsController.text.trim(),
      );

      await cadastrarAgendamento(novo, _token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento realizado com sucesso!'),
            backgroundColor: Color(0xFF16a34a),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafafa),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4b4b4b),
        title: const Text(
          'Novo Agendamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Seleção de sala ──
            _secao('Sala'),
            GestureDetector(
              onTap: _abrirSeletorSala,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFcbd5e1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.meeting_room, color: Color(0xFF4b4b4b)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _salaSelecionada != null
                            ? '${_salaSelecionada!.nome} — Nº ${_salaSelecionada!.numero}'
                            : 'Toque para selecionar a sala',
                        style: TextStyle(
                          fontSize: 15,
                          color: _salaSelecionada != null
                              ? const Color(0xFF1e293b)
                              : const Color(0xFF94a3b8),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF64748b),
                    ),
                  ],
                ),
              ),
            ),

            // ── Horários fixos da sala ──
            if (_salaSelecionada != null) ...[
              const SizedBox(height: 20),
              _secao('Horários da sala (semana)'),
              _carregandoHorarios
                  ? const Center(child: CircularProgressIndicator())
                  : _buildGradeSemanal(),

              const SizedBox(height: 20),
              _secao('Agendamentos existentes'),
              _buildListaAgendamentos(),
            ],

            const SizedBox(height: 20),

            // ── Data ──
            _secao('Data'),
            GestureDetector(
              onTap: _selecionarData,
              child: _campoLeitura(
                icone: Icons.calendar_today,
                texto: _dataSelecionada != null
                    ? _formatarData(_dataSelecionada!)
                    : 'Selecionar data',
              ),
            ),

            const SizedBox(height: 16),

            // ── Hora início / fim ──
            _secao('Horário'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selecionarHora(isInicio: true),
                    child: _campoLeitura(
                      icone: Icons.access_time,
                      texto: _horaInicio != null
                          ? _formatarHora(_horaInicio!)
                          : 'Início',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selecionarHora(isInicio: false),
                    child: _campoLeitura(
                      icone: Icons.access_time_filled,
                      texto: _horaFim != null
                          ? _formatarHora(_horaFim!)
                          : 'Fim',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Observação ──
            _secao('Observação'),
            TextField(
              controller: _obsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Aula de banco de dados',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFcbd5e1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFcbd5e1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4b4b4b)),
                ),
              ),
            ),

            // ── Erro ──
            if (_erro.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _erro,
                style: const TextStyle(color: Color(0xFFef4444), fontSize: 14),
              ),
            ],

            const SizedBox(height: 24),

            // ── Botão agendar ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4b4b4b),
                  disabledBackgroundColor: const Color(
                    0xFF4b4b4b,
                  ).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  _salvando ? 'Agendando...' : 'Confirmar Agendamento',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Grade semanal de horários fixos ──────────────────
  Widget _buildGradeSemanal() {
    if (_horariosSala.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: const Text(
          'Nenhum horário fixo cadastrado para esta sala.',
          style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
        ),
      );
    }

    return Column(
      children: List.generate(7, (i) {
        final diaIndex = i + 1; // 1=Seg ... 7=Dom
        final nomeDia = _nomesDia[diaIndex];
        final chave = _diasSemana[i];
        final blocos = _horariosSala
            .where((h) => h.diaSemana.toLowerCase() == chave)
            .toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label do dia
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: blocos.isNotEmpty
                      ? const Color(0xFF4b4b4b)
                      : const Color(0xFFf1f5f9),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                ),
                child: Text(
                  nomeDia,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: blocos.isNotEmpty
                        ? Colors.white
                        : const Color(0xFF94a3b8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Blocos do dia
              Expanded(
                child: blocos.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Livre',
                          style: TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: blocos.map((b) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFdbeafe),
                                borderRadius: BorderRadius.circular(8),
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xFF1d4ed8),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${b.horaInicio} — ${b.horaFim}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1d4ed8),
                                    ),
                                  ),
                                  if (b.turmaNome.isNotEmpty)
                                    Text(
                                      b.turmaNome,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748b),
                                      ),
                                    ),
                                  if (b.disciplina.isNotEmpty)
                                    Text(
                                      b.disciplina,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748b),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Lista de agendamentos existentes da sala ──────────
  Widget _buildListaAgendamentos() {
    final hoje = DateTime.now();
    final agsValidos = _agendamentosSala.where((ag) {
      if (ag.dataHoraInicio.length < 10) return false;
      final data = DateTime.tryParse(ag.dataHoraInicio);
      if (data == null) return false;
      return !data.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
    }).toList();

    if (agsValidos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: const Text(
          'Nenhum agendamento futuro para esta sala.',
          style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
        ),
      );
    }

    return Column(
      children: agsValidos.map((ag) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
              const Icon(Icons.event, color: Color(0xFF1d4ed8), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extrairData(ag.dataHoraInicio),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_extrairHora(ag.dataHoraInicio)} — ${_extrairHora(ag.dataHoraFim)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1d4ed8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (ag.obs.isNotEmpty)
                      Text(
                        ag.obs,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748b),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _secao(String titulo) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      titulo,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4b4b4b),
      ),
    ),
  );

  Widget _campoLeitura({required IconData icone, required String texto}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFcbd5e1)),
        ),
        child: Row(
          children: [
            Icon(icone, color: const Color(0xFF4b4b4b), size: 20),
            const SizedBox(width: 10),
            Text(
              texto,
              style: TextStyle(
                fontSize: 15,
                color:
                    texto.contains('Selecionar') ||
                        texto == 'Início' ||
                        texto == 'Fim'
                    ? const Color(0xFF94a3b8)
                    : const Color(0xFF1e293b),
              ),
            ),
          ],
        ),
      );
}
