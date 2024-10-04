class Discussao {
  final int id;
  final String titulo;
  final String autor;
  final String data;

  Discussao({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.data,
  });

  factory Discussao.fromJson(Map<String, dynamic> json) {
    return Discussao(
      id: json['id'],
      titulo: json['titulo'],
      autor: json['autor'],
      data: json['data'],
    );
  }
}
