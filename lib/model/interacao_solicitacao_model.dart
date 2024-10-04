class InteracaoSolicitacao {
  final int id;
  final String mensagem;
  final String data;

  InteracaoSolicitacao({
    required this.id,
    required this.mensagem,
    required this.data,
  });

  factory InteracaoSolicitacao.fromJson(Map<String, dynamic> json) {
    return InteracaoSolicitacao(
      id: json['id'],
      mensagem: json['mensagem'],
      data: json['data'],
    );
  }
}