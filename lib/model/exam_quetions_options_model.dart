class Opcao {
  final int id;
  final String texto;
  bool isSelected;

  Opcao({
    required this.id,
    required this.texto,
    this.isSelected = false,
  });

  factory Opcao.fromJson(Map<String, dynamic> json) {
    return Opcao(
      id: json['id'],
      texto: json['texto'],
      isSelected: false,
    );
  }
}


class Pergunta {
  final int id;
  final String pergunta;
  final List<Opcao> opcoes;

  Pergunta({required this.id, required this.pergunta, required this.opcoes});

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'],
      pergunta: json['pergunta'],
      opcoes: (json['opcoes'] as List)
        .map((opcaoJson) => Opcao.fromJson(opcaoJson as Map<String,dynamic>))
        .toList(),
    );
  }
}
