class Solicitacao {
  final int id;
  final String titulo;
  final String status;

  Solicitacao({
    required this.id,
    required this.titulo,
    required this.status,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: json['id'],
      titulo: json['titulo'],
      status: json['status'],
    );
  }
}
