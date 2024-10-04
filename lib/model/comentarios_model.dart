class Comentario {
  final int id;
  final String comment;
  final String autor;
  final String data;
  final int? comment_id;

  Comentario({
    required this.id,
    required this.comment,
    required this.autor,
    required this.data,
    required this.comment_id,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      comment: json['comment'],
      autor: json['autor'],
      data: json['data'],
      comment_id: json['comment_id'],
    );
  }
}
