// lib/features/auth/models/agendamento_sala_model.dart
class AgendamentoSala {
  final int? id;
  final int salaId;
  final String dataHoraInicio;
  final String dataHoraFim;
  final String obs;

  AgendamentoSala({
    this.id,
    required this.salaId,
    required this.dataHoraInicio,
    required this.dataHoraFim,
    required this.obs,
  });

  factory AgendamentoSala.fromJson(Map<String, dynamic> j) => AgendamentoSala(
    id: j['id'],
    salaId: j['sala_id'],
    dataHoraInicio: j['data_hora_inicio'] ?? '',
    dataHoraFim: j['data_hora_fim'] ?? '',
    obs: j['obs'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'sala_id': salaId,
    'data_hora_inicio': dataHoraInicio,
    'data_hora_fim': dataHoraFim,
    'obs': obs,
  };
}
