class ExameDisciplina {
  final int id;
  final String prova;
  final String data;

  ExameDisciplina({required this.id, required this.prova, required this.data});

  factory ExameDisciplina.fromJson(Map<String, dynamic> json){
    return ExameDisciplina(id: json['id'], prova: json['prova'], data: json['data']);
  }
}