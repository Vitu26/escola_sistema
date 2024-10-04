import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/interacao_solicitacao_model.dart';

class DetalhesSolicitacoesPage extends StatefulWidget {
  final int solicitacaoId;
  const DetalhesSolicitacoesPage({Key? key, required this.solicitacaoId}) : super(key: key);

  @override
  State<DetalhesSolicitacoesPage> createState() => _DetalhesSolicitacoesPageState();
}

class _DetalhesSolicitacoesPageState extends State<DetalhesSolicitacoesPage> {
  List<InteracaoSolicitacao> interacoes = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _mensagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDetalhesSolicitacao();
  }

  Future<void> fetchDetalhesSolicitacao() async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/detalhes_solicitacao');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'solicitacao_id': widget.solicitacaoId.toString(),
        },
      );
      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          interacoes = data
              .map((interacaoJson) => InteracaoSolicitacao.fromJson(
                  interacaoJson as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        print('Erro na resposta da API: ${response.body}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar interações: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> adicionarInteracao() async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/adicionar_interacao');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'solicitacao_id': widget.solicitacaoId.toString(),
          'mensagem': _mensagemController.text,
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensagem'] ?? 'Interação adicionada com sucesso')),
        );
        _mensagemController.clear();
        fetchDetalhesSolicitacao(); // Recarrega as interações após adicionar uma nova
      } else {
        print('Erro na resposta da API: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar interação')),
        );
      }
    } catch (e) {
      print('Erro ao adicionar interação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar interação')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Solicitação'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar interações.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: interacoes.length,
                        itemBuilder: (context, index) {
                          final interacao = interacoes[index];
                          return ListTile(
                            title: Text(interacao.mensagem),
                            subtitle: Text('Data: ${interacao.data}'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _mensagemController,
                            decoration: InputDecoration(
                              labelText: 'Adicionar mensagem',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: adicionarInteracao,
                            child: Text('Adicionar Interação'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
