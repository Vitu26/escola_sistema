// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app/model/atividade_disciplina_model.dart';
import 'package:app/widgets/drawer.dart';

class AtividadeDisciplinaPage extends StatefulWidget {
  final int disciplinaId;
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const AtividadeDisciplinaPage({
    Key? key,
    required this.disciplinaId,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<AtividadeDisciplinaPage> createState() =>
      _AtividadeDisciplinaPageState();
}

class _AtividadeDisciplinaPageState extends State<AtividadeDisciplinaPage> {
  List<AtividadesDisiciplinas> atividades = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Disiciplinas';
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'atividades_cache';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchAtividadeDisciplinas();
  }

  Future<void> fetchAtividadeDisciplinas() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final cacheData = await cacheManager.getFromCache(cacheKey);
    if (cacheData != null) {
      setState(() {
        atividades = (jsonDecode(cacheData) as List)
            .map((atividadesJson) =>
                AtividadesDisiciplinas.fromJson(atividadesJson))
            .toList();
      });
    }

    final url = Uri.parse(
        'https://app.tresmarias.edu.br/api/v1/atividades_disciplines');
    try {
      final response = await http.post(
        url,
        body: {
          'discipline_id': widget.disciplinaId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          atividades = data
              .map((atividadesJson) =>
                  AtividadesDisiciplinas.fromJson(atividadesJson))
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
      print(e);
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
          idMatricula: widget.idMatricula,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: atividades.length,
                itemBuilder: (context, index) {
                  final atividade = atividades[index];
                  return ListTile(
                    title: Text(atividade.atividade!),
                    subtitle: Text('Prazo: ${atividade.prazo}'),
                  );
                }));
  }
}
