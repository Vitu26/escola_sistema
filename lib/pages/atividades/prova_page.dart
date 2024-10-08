import 'dart:convert';
import 'package:app/model/exam_quetions_options_model.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProvaPage extends StatefulWidget {
  final int exameId;
  final int disciplineId;
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const ProvaPage({
    super.key,
    required this.exameId,
    required this.disciplineId,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  });

  @override
  State<ProvaPage> createState() => _ProvaPageState();
}

class _ProvaPageState extends State<ProvaPage> {
  List<Pergunta> perguntas = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Prova';
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'perguntas_cache';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchPerguntas();
  }

  Future<void> fetchPerguntas() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    //tenta carregar as disciplinas do cache
    final cachedData = await cacheManager.getFromCache(cacheKey);
    if (cachedData != null) {
      //se os dados existirem , carrega-os
      setState(() {
        perguntas = (jsonDecode(cachedData) as List)
            .map((perguntaJson) => Pergunta.fromJson(perguntaJson))
            .toList();
        isLoading = false;
      });
      return;
    }
    final url = Uri.parse(
        'https://app.tresmarias.edu.br/api/v1/exams_questions_and_options');

    // Exibindo os valores e tipos de dados para depuração
    print('exam_id: ${widget.exameId}, tipo: ${widget.exameId.runtimeType}');
    print(
        'discipline_id: ${widget.disciplineId}, tipo: ${widget.disciplineId.runtimeType}');

    try {
      // Construindo manualmente o corpo da requisição para tentar preservar os tipos de dados
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'exam_id':
              '${widget.exameId}', // Garantindo a passagem como string formatada, mas aceitando int no backend
          'discipline_id': '${widget.disciplineId}',
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          perguntas = data
              .map((perguntaJson) =>
                  Pergunta.fromJson(perguntaJson as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        print('Erro: ${response.body}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void selecionarOpcao(Pergunta pergunta, Opcao opcaoSelecionada) {
    setState(() {
      for (var opcao in pergunta.opcoes) {
        opcao.isSelected = opcao == opcaoSelecionada;
      }
    });
  }

  Future<void> responderProva() async {
    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/responder_prova');

    final respostas = perguntas
        .map((pergunta) => {
              'pergunta_id': pergunta.id,
              'resposta': pergunta.opcoes
                  .firstWhere((opcao) => opcao.isSelected,
                      orElse: () => Opcao(id: 0, texto: '', isSelected: false))
                  .id
            })
        .where((resposta) =>
            resposta['resposta'] != 0) // Filtra as respostas não respondidas
        .toList();

    if (respostas.isEmpty) {
      _showAlert('Erro', 'Você precisa selecionar pelo menos uma resposta.');
      return;
    }
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {
    //       "Content-Type": "application/json",
    //     },
    //     body: json.encode({
    //       'exam_id': widget.exameId,
    //       'respostas': respostas,
    //     }),
    //   );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'exam_id': widget.exameId.toString(),
          'respostas': json.encode(respostas),
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showAlert('Sucesso', responseData['mensagem']);
      } else {
        _showAlert(
            'Erro', responseData['mensagem'] ?? 'Erro ao enviar respostas.');
      }
    } catch (e) {
      _showAlert('Erro', 'Falha ao enviar respostas. Tente novamente.');
    }
  }

  // Função para exibir um alerta
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perguntas da Prova'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : hasError
              ? Center(child: Text('Erro ao carregar perguntas.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: perguntas.length,
                        itemBuilder: (context, index) {
                          final pergunta = perguntas[index];
                          return ExpansionTile(
                            title: Text(pergunta.pergunta),
                            children: pergunta.opcoes.map((opcao) {
                              return ListTile(
                                title: Text(opcao.texto),
                                trailing: opcao.isSelected
                                    ? Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : Icon(Icons.circle_outlined),
                                onTap: () {
                                  selecionarOpcao(pergunta, opcao);
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: responderProva,
                        child: const Text('Enviar Respostas'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
