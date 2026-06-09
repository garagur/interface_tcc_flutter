import 'package:flutter/material.dart';
import 'package:tcc_yoji/features/auth/services/Itens_Services/salaServices/List_Sala_Services.dart';
import 'package:tcc_yoji/features/auth/services/Itens_Services/equipamentoServices/List_equipamento_Services.dart';
import 'package:tcc_yoji/features/auth/models/item_agendamento.dart';

class AgendamentoController extends ChangeNotifier {
  final String token;
  final String matricula;

  AgendamentoController({required this.token, required this.matricula});

  // ── Form state ──
  DateTime dataAgendamento = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay horaFim = const TimeOfDay(hour: 10, minute: 0);
  String obs = '';

  // ── Data ──
  List<ItemAgendamento> salas = [];
  List<ItemAgendamento> equipamentos = [];
  bool carregandoLista = false;

  // ── Selecionados ──
  List<ItemAgendamento> itensSelecionados = [];

  // ── Filtros ──
  String filtroTipo = 'todos'; // 'todos', 'sala', 'equipamento'
  String filtroBusca = '';

  // ── UI state ──
  bool carregando = false;
  String erro = '';
  String sucesso = '';

  List<ItemAgendamento> get todosItens => [...salas, ...equipamentos];

  List<ItemAgendamento> get itensFiltrados => todosItens.where((item) {
    final matchTipo = filtroTipo == 'todos' || item.tipo == filtroTipo;
    final matchBusca = item.nome.toLowerCase().contains(
      filtroBusca.toLowerCase(),
    );
    return matchTipo && matchBusca;
  }).toList();

  bool jaSelecionado(int id, String tipo) =>
      itensSelecionados.any((i) => i.id == id && i.tipo == tipo);

  Future<void> carregarLista() async {
    carregandoLista = true;
    erro = '';
    notifyListeners();

    try {
      final salaService = SalaService(
        /* seu Dio aqui, ex: DioClient.instance */ null as dynamic,
      );
      final equipamentoService = EquipamentoService(null as dynamic);

      final resultSalas = await salaService.carregarSalas(token);
      final resultEquipamentos = await equipamentoService.carregarEquipamentos(
        token,
      );

      salas = resultSalas
          .map((m) => ItemAgendamento.fromMap(m, 'sala'))
          .toList();
      equipamentos = resultEquipamentos
          .map((m) => ItemAgendamento.fromMap(m, 'equipamento'))
          .toList();
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      carregandoLista = false;
      notifyListeners();
    }
  }

  void adicionarItem(ItemAgendamento item) {
    if (!item.status) return;
    if (jaSelecionado(item.id, item.tipo)) return;
    itensSelecionados = [...itensSelecionados, item];
    notifyListeners();
  }

  void removerItem(int id, String tipo) {
    itensSelecionados = itensSelecionados
        .where((i) => !(i.id == id && i.tipo == tipo))
        .toList();
    notifyListeners();
  }

  void setFiltroTipo(String tipo) {
    filtroTipo = tipo;
    notifyListeners();
  }

  void setFiltroBusca(String busca) {
    filtroBusca = busca;
    notifyListeners();
  }

  void setObs(String value) {
    obs = value;
    notifyListeners();
  }

  void setData(DateTime data) {
    dataAgendamento = data;
    notifyListeners();
  }

  void setHoraInicio(TimeOfDay hora) {
    horaInicio = hora;
    notifyListeners();
  }

  void setHoraFim(TimeOfDay hora) {
    horaFim = hora;
    notifyListeners();
  }

  bool get horaValida {
    final inicioMin = horaInicio.hour * 60 + horaInicio.minute;
    final fimMin = horaFim.hour * 60 + horaFim.minute;
    return inicioMin < fimMin;
  }

  Future<void> salvarAgendamento() async {
    erro = '';
    sucesso = '';

    if (itensSelecionados.isEmpty) {
      erro = 'Selecione pelo menos um item para agendar.';
      notifyListeners();
      return;
    }
    if (!horaValida) {
      erro = 'A hora de início deve ser anterior à hora de fim.';
      notifyListeners();
      return;
    }

    carregando = true;
    notifyListeners();

    try {
      final payload = {
        'matricula': matricula,
        'data': dataAgendamento.toIso8601String().substring(0, 10),
        'hora_inicio':
            '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
        'hora_fim':
            '${horaFim.hour.toString().padLeft(2, '0')}:${horaFim.minute.toString().padLeft(2, '0')}',
        'obs': obs,
        'itens': itensSelecionados
            .map((i) => {'id': i.id, 'tipo': i.tipo})
            .toList(),
      };

      // TODO: await criarAgendamento(payload, token);
      debugPrint('Payload agendamento: $payload');

      sucesso = 'Agendamento realizado com sucesso.';
      resetForm();
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void resetForm() {
    dataAgendamento = DateTime.now();
    horaInicio = const TimeOfDay(hour: 8, minute: 0);
    horaFim = const TimeOfDay(hour: 10, minute: 0);
    obs = '';
    itensSelecionados = [];
    notifyListeners();
  }
}
