class ItemAgendamento {
  final int id;
  final String nome;
  final String tipo; // 'sala' ou 'equipamento'
  final bool status;
  final String numero;
  final String obs;

  ItemAgendamento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.status,
    this.numero = '',
    this.obs = '',
  });

  factory ItemAgendamento.fromMap(Map<String, dynamic> map, String tipo) {
    return ItemAgendamento(
      id: map['id'],
      nome: map['nome'] ?? '',
      tipo: tipo,
      status: map['status'] ?? true,
      numero: map['numero'] ?? '',
      obs: map['obs'] ?? '',
    );
  }

  String get tipoLabel => tipo == 'sala' ? 'Sala' : 'Equipamento';

  @override
  bool operator ==(Object other) =>
      other is ItemAgendamento && other.id == id && other.tipo == tipo;

  @override
  int get hashCode => Object.hash(id, tipo);
}
