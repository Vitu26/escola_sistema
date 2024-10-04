class MaterialDisciplina {
  final int id;
  final String titulo;
  final String link;

  MaterialDisciplina({
    required this.id,
    required this.titulo,
    required this.link,
  });

  factory MaterialDisciplina.fromJson(Map<String, dynamic> json) {
    return MaterialDisciplina(
      id: json['id'],
      titulo: json['titulo'],
      link: json['link'],
    );
  }
}
