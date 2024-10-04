class Disciplina {
  final int id;
  final String discipline;
  final String? professor;
  final String? codigo;

  Disciplina({required this.id, required this.discipline, required this.professor, required this.codigo});

  factory Disciplina.fromJson(Map<String, dynamic> json){
    return Disciplina(
      id: json['id'],
      discipline: json['discipline'],
      professor: json['professor'] ?? '',
      codigo: json['codigo'] ?? '',
    );
  }
}