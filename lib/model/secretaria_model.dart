class Documento {
  final String nome;
  final String link;

  Documento({
    required this.nome,
    required this.link,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      nome: json['nome'],
      link: json['link'],
    );
  }
}
