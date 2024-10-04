class AtividadesDisiciplinas {
  final int id;
  final String? atividade;
  final String? prazo;
  final String? upload;

  AtividadesDisiciplinas(
      {required this.id,
      required this.atividade,
      required this.prazo,
      required this.upload});

  factory AtividadesDisiciplinas.fromJson(Map<String, dynamic> json) {
    return AtividadesDisiciplinas(
      id: json['id'],
      atividade: json['atividade']?? '',
      prazo: json['prazo']?? '',
      upload: json['upload']?? '',
    );
  }
}
