import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdicionarSolicitacaoPage extends StatefulWidget {
  @override
  _AdicionarSolicitacaoPageState createState() =>
      _AdicionarSolicitacaoPageState();
}

class _AdicionarSolicitacaoPageState extends State<AdicionarSolicitacaoPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  bool isLoading = false;
  String? feedbackMessage;

  Future<void> adicionarSolicitacao() async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/adicionar_solicitacao');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'titulo': _tituloController.text,
          'status': _statusController.text,
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          feedbackMessage = data['mensagem'] ?? 'Solicitação adicionada com sucesso';
          isLoading = false;
        });
      } else {
        setState(() {
          feedbackMessage = 'Erro ao adicionar solicitação: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao adicionar solicitação: $e');
      setState(() {
        feedbackMessage = 'Erro ao adicionar solicitação: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Solicitação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título da Solicitação',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status da Solicitação',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : adicionarSolicitacao,
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Adicionar Solicitação'),
            ),
            if (feedbackMessage != null) ...[
              SizedBox(height: 16),
              Text(
                feedbackMessage!,
                style: TextStyle(
                  color: feedbackMessage!.contains('sucesso')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
