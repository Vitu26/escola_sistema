class Biblioteca {
  final int id;
  final String biblioteca;

  Biblioteca({
    required this.id,
    required this.biblioteca,
  });

  factory Biblioteca.fromJson(Map<String, dynamic> json) {
    return Biblioteca(
      id: json['id'],
      biblioteca: json['biblioteca'],
    );
  }
}
