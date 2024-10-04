import 'dart:convert';
import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/exame_disciplina_model.dart';
import 'package:app/pages/atividades/prova_page.dart';
import 'package:app/widgets/drawer.dart';

class ExameDisciplinaPage extends StatefulWidget {
  final int disciplineId;
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const ExameDisciplinaPage({
    Key? key,
    required this.disciplineId,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<ExameDisciplinaPage> createState() => _ExameDisciplinaPageState();
}

class _ExameDisciplinaPageState extends State<ExameDisciplinaPage> {
  List<ExameDisciplina> exames = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Disciplinas';
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'disciplinas_cache';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchExameDisciplina();
  }

  Future<void> fetchExameDisciplina() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    //tenta carregar as disciplinas do cache
    final cachedData = await cacheManager.getFromCache(cacheKey);
    if (cachedData != null) {
      //se os dados existirem , carrega-os
      setState(() {
        exames = (jsonDecode(cachedData) as List)
            .map((examesJson) => ExameDisciplina.fromJson(examesJson))
            .toList();
        isLoading = false;
      });
      return;
    }

    
    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/exams_disciplines');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'discipline_id': '${widget.disciplineId}',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          exames = data
              .map((examesJson) =>
                  ExameDisciplina.fromJson(examesJson as Map<String, dynamic>))
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
      appBar: AppBar(
        title: Text('Provas da Disciplina'),
      ),
      drawer: CustomDrawer(
        onItemTap: onItemTap,
        nomeAluno: widget.nomeAluno,
        idMatricula: widget.idMatricula,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar provas.'))
              : ListView.builder(
                  itemCount: exames.length,
                  itemBuilder: (context, index) {
                    final exame = exames[index];
                    return ListTile(
                      title: Text(exame.prova),
                      subtitle: Text('Data: ${exame.data}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProvaPage(
                              exameId: exame.id,
                              disciplineId: widget.disciplineId,
                              nomeAluno: widget.nomeAluno,
                              idMatricula: widget.idMatricula,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
