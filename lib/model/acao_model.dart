class Acao {
  final String tipo;
  final String link;

  Acao({required this.tipo, required this.link});

  factory Acao.fromJson(Map<String, dynamic> json) {
    return Acao(
      tipo: json['tipo'],
      link: json['link'],
    );
  }
}