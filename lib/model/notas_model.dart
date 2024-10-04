class Nota {
  final String disciplina;
  final double? nota;

  Nota({required this.disciplina, required this.nota});

 factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      disciplina: json['disciplina'] ?? 'Disciplina desconhecida', // Tratar caso seja null
      nota: json['nota'] != null ? json['nota'].toDouble() : null, // Tratar caso seja null
    );
  }
}
