import 'dart:convert';

import 'package:app/model/solicitacoes_model.dart';
import 'package:app/pages/solicitacoes/detalhes_solicitacoes_page.dart';
import 'package:app/widgets/custom_app_bar.dart';
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
        backgroundColor: const Color(0xFF094366),
        appBar: CustomAppbar(title: selectedPage),
        drawer: CustomDrawer(
            onItemTap: onItemTap,
            nomeAluno: widget.nomeAluno,
            idMatricula: widget.idMatricula),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Solicitações',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(
                          height: 3,
                          thickness: 2,
                          color: Colors.black,
                        ),
                        Container(
                          color: Colors.white,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: solicitacoes.length,
                              itemBuilder: (context, index) {
                                final solicitacao = solicitacoes[index];
                                return Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(solicitacao.titulo),
                                    subtitle: Text(solicitacao.status),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetalhesSolicitacoesPage(
                                                    solicitacaoId:
                                                        solicitacao.id,
                                                  )));
                                    },
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                ],
              ));
  }
}
