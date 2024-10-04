class Laboratorios {
  final int id;
  final String laboratorio;

  Laboratorios({
    required this.id,
    required this.laboratorio,
  });

  factory Laboratorios.fromJson(Map<String, dynamic> json) {
    return Laboratorios(
      id: json['id'],
      laboratorio: json['laboratorio'],
    );
  }
}
