// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdicionarInteracaoPage extends StatefulWidget {
  final int solicitacaoId;
  const AdicionarInteracaoPage({
    Key? key,
    required this.solicitacaoId,
  }) : super(key: key);

  @override
  State<AdicionarInteracaoPage> createState() => _AdicionarInteracaoPageState();
}

class _AdicionarInteracaoPageState extends State<AdicionarInteracaoPage> {
  final TextEditingController _mensagemController = TextEditingController();
  bool isLoading = false;
  String? feedbackMessage;

  Future<void> adicionarInteracao() async {
    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/adicionar_interacao');

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
          'solicitacao_id': widget.solicitacaoId.toString(),
          'mensagem': _mensagemController.text,
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          feedbackMessage = data['mensagem'];
          isLoading = false;
        });
      } else {
        setState(() {
          feedbackMessage = 'Erro ao adicionar interação: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao adicionar interação: $e');
      setState(() {
        feedbackMessage = 'Erro ao adicionar interação: $e';
        isLoading = false;
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Interação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _mensagemController,
              decoration: InputDecoration(
                labelText: 'Digite a mensagem',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : adicionarInteracao,
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Adicionar Interação'),
            ),
            const SizedBox(height: 20),
            if (feedbackMessage != null)
              Text(
                feedbackMessage!,
                style: TextStyle(
                  color: feedbackMessage!.contains('sucesso') ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}