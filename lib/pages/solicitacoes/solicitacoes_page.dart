import 'dart:convert';

import 'package:app/model/detalhes_solicitacoes_model.dart';
import 'package:app/model/solicitacoes_model.dart';
import 'package:app/pages/solicitacoes/detalhes_solicitacoes_page.dart';
import 'package:app/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SolicitacoesPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const SolicitacoesPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  List<Solicitacao> solicitacoes = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Solicitações';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchSolicitacoes();
  }

  Future<void> fetchSolicitacoes() async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/solicitacoes');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          solicitacoes = data
              .map((solicitacaoJson) =>
                  Solicitacao.fromJson(solicitacaoJson as Map<String, dynamic>))
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
      print('Erro na resposta da API: ${e}');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(
          onItemTap: onItemTap,
          nomeAluno: widget.nomeAluno,
          idMatricula: widget.idMatricula),
      body: isLoading ?
        Center(child: CircularProgressIndicator(),)
        : ListView.builder(
          itemCount: solicitacoes.length,
          itemBuilder: (context, index){
            final solicitacao = solicitacoes[index];
            return ListTile(
              title: Text(solicitacao.titulo),
              subtitle: Text(solicitacao.status),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetalhesSolicitacoesPage(solicitacaoId: solicitacao.id,)));
              },
            );
          })
    );
  }
}
