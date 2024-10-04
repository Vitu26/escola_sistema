import 'package:app/model/acao_model.dart';
import 'package:intl/intl.dart'; // Para lidar com datas

class Parcela {
  final int transactionId;
  final String invoiceId;
  final String referencia;
  final String dataVencimento;
  final String valor;
  final String status;
  final Acao? acao;

  Parcela({
    required this.transactionId,
    required this.invoiceId,
    required this.referencia,
    required this.dataVencimento,
    required this.valor,
    required this.status,
    this.acao,
  });

  // Adicionando o getter isVencida
  bool get isVencida {
    try {
      // Converte a dataVencimento para um objeto DateTime
      final vencimento = DateFormat('dd/MM/yyyy').parse(dataVencimento);
      // Compara a data de vencimento com a data atual
      return DateTime.now().isAfter(vencimento);
    } catch (e) {
      print('Erro ao analisar a data de vencimento: $e');
      return false; // Retorna false se houver algum erro no parsing
    }
  }

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      transactionId: int.parse(json['transaction_id']),
      invoiceId: json['invoice_id'],
      referencia: json['referencia'],
      dataVencimento: json['data_vencimento'],
      valor: json['valor'],
      status: json['status'],
      acao: json['acao'] is Map<String, dynamic>
          ? Acao.fromJson(json['acao'])
          : null,
    );
  }
}
