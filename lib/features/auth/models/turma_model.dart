class Turma {
  final int id;
  final String nome;
  final String anoLetivo;

  Turma({required this.id, required this.nome, required this.anoLetivo});

  factory Turma.fromJson(Map<String, dynamic> j) => Turma(
    id: j['id'],
    nome: j['nome'] ?? '',
    anoLetivo: j['ano_letivo'] ?? '',
  );
}
