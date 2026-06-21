// lib/features/home/models/horario_model.dart
class Horario {
  final int id;
  final dynamic turmaid;
  final String turmaNome;
  final dynamic salaId;
  final String salaNome;
  final dynamic professorId;
  final String professorNome;
  final String diaSemana;
  final String disciplina;
  final String horaInicio;
  final String horaFim;

  Horario({
    required this.id,
    required this.turmaid,
    required this.turmaNome,
    required this.salaId,
    required this.salaNome,
    required this.professorId,
    this.professorNome = '',
    required this.diaSemana,
    required this.disciplina,
    required this.horaInicio,
    required this.horaFim,
  });

  factory Horario.fromJson(Map<String, dynamic> j) => Horario(
    id: j['id'],
    turmaid: j['turma']?['id'] ?? j['turma_id'] ?? '',
    turmaNome: j['turma']?['nome'] ?? '',
    salaId: j['sala']?['id'] ?? j['sala_id'] ?? '',
    salaNome: j['sala']?['nome'] ?? '',
    professorId: j['professor']?['id'] ?? j['professor_id'] ?? '',
    professorNome: j['professor']?['name'] ?? '',
    diaSemana: j['dia_semana'] ?? '',
    disciplina: j['disciplina'] ?? '',
    horaInicio: j['hora_inicio'] ?? '',
    horaFim: j['hora_fim'] ?? '',
  );
}
