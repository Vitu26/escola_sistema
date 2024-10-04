class DetalhesSolicitacoes {
  final int id;
  final String mensagem;
  final String data;

  DetalhesSolicitacoes({
    required this.id,
    required this.mensagem,
    required this.data,
  });

  factory DetalhesSolicitacoes.fromJson(Map<String, dynamic> json) {
    return DetalhesSolicitacoes(
      id: json['id'],
      mensagem: json['mensagem'],
      data: json['data'],
    );
  }
}
