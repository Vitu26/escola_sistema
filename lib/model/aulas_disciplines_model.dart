class Aulas {
  final int id;
  final String aula;
  final String link;

  Aulas({
    required this.id,
    required this.aula,
    required this.link,
  });

  factory Aulas.fromJson(Map<String, dynamic> json) {
    return Aulas(
      id: json['id'],
      aula: json['aula'],
      link: json['link'],
    );
  }
}
