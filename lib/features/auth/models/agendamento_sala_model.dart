// lib/features/auth/models/agendamento_sala_model.dart
class AgendamentoSala {
  final int? id;
  final int? userId;
  final String usuarioNome;
  final int salaId;
  final String salaNome;
  final String dataHoraInicio;
  final String dataHoraFim;
  final String obs;

  AgendamentoSala({
    this.id,
    this.userId,
    this.usuarioNome = '',
    required this.salaId,
    this.salaNome = '',
    required this.dataHoraInicio,
    required this.dataHoraFim,
    required this.obs,
  });

  factory AgendamentoSala.fromJson(Map<String, dynamic> j) => AgendamentoSala(
    id: j['id'],
    userId: j['user_id'],
    usuarioNome: j['usuario_nome'] ?? '',
    salaId: j['sala_id'],
    salaNome: j['sala_nome'] ?? '',
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

  bool get isFuturo {
    final inicio = DateTime.tryParse(dataHoraInicio);
    if (inicio == null) return false;
    return inicio.isAfter(DateTime.now()) ||
        inicio.isAtSameMomentAs(DateTime.now());
  }
}
