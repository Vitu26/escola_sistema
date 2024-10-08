import 'dart:convert';
import 'package:app/model/disciplinas_model.dart';
import 'package:app/pages/atividades/atividade_disciplina_page.dart';
import 'package:app/pages/atividades/aulas_disciplinas_page.dart';
import 'package:app/pages/atividades/exame_disciplina_page.dart';
import 'package:app/pages/forum/forum_page.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisciplinaPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const DisciplinaPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<DisciplinaPage> createState() => _DisciplinaPageState();
}

class _DisciplinaPageState extends State<DisciplinaPage> {
  List<Disciplina> disciplinas = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Disiciplinas';
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
    fetchDisciplinas();
  }

  Future<void> fetchDisciplinas() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    //tenta carregar as disciplinas do cache
    final cachedData = await cacheManager.getFromCache(cacheKey);
    if (cachedData != null) {
      //se os dados existirem , carrega-os
      setState(() {
        disciplinas = (jsonDecode(cachedData) as List)
            .map((disciplinaJson) => Disciplina.fromJson(disciplinaJson))
            .toList();
        isLoading = false;
      });
      return;
    }

    //caso o cache não exista, faz a requisição a Api
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/disciplines');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          disciplinas = data
              .map((disciplinaJson) => Disciplina.fromJson(disciplinaJson))
              .toList();
          isLoading = false;
        });

        // Salva os dados no cache para uso futuro
        await cacheManager.saveToCache(cacheKey, response.body);
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void navigateToOption(BuildContext context, String option, int disciplineId) {
    switch (option) {
      case 'Aulas':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AulasDisciplinasPage(disciplineId: disciplineId),
          ),
        );
        break;
      case 'Atividades':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AtividadeDisciplinaPage(
              disciplinaId: disciplineId,
              nomeAluno: widget.nomeAluno,
              idMatricula: widget.idMatricula,
            ),
          ),
        );
        break;
      case 'Provas':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExameDisciplinaPage(
              disciplineId: disciplineId,
              nomeAluno: widget.nomeAluno,
              idMatricula: widget.idMatricula,
            ),
          ),
        );
        break;
      case 'Questões e Opções':
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         ExamsQuestionsPage(disciplineId: disciplineId),
        //   ),
        // );
        break;
      case 'Forum':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ForumDisciplinePage(disciplineId: disciplineId),
          ),
        );
        break;
    }
  }

  void showOptionsDialog(BuildContext context, int disciplineId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Aulas'),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, 'Aulas', disciplineId);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Atividades'),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, 'Atividades', disciplineId);
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Provas'),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, 'Provas', disciplineId);
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Questões e Opções'),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, 'Questões e Opções', disciplineId);
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Forum'),
              onTap: () {
                Navigator.pop(context);
                navigateToOption(context, 'Forum', disciplineId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Disciplinas'),
      drawer: CustomDrawer(
        onItemTap: onItemTap,
        nomeAluno: widget.nomeAluno,
        idMatricula: widget.idMatricula,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar as disciplinas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: disciplinas.length,
                  itemBuilder: (context, index) {
                    final disciplina = disciplinas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          disciplina.discipline,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Professor: ${disciplina.professor}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          showOptionsDialog(context, disciplina.id);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
