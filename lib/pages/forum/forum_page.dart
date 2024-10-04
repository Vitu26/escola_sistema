import 'dart:convert';

import 'package:app/model/discussao_model.dart';
import 'package:app/pages/forum/forums_comment_page.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForumDisciplinePage extends StatefulWidget {
  final int disciplineId;
  const ForumDisciplinePage({super.key, required this.disciplineId});

  @override
  State<ForumDisciplinePage> createState() => _ForumDisciplinePageState();
}

class _ForumDisciplinePageState extends State<ForumDisciplinePage> {
  List<Discussao> discussoes = [];
  bool isLoading = true;
  bool hasError = false;
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'discussoes_cache';

  @override
  void initState() {
    super.initState();
    fetchDiscussao();
  }

  Future<void> fetchDiscussao() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final cacheData = await cacheManager.getFromCache(cacheKey);
    if(cacheData != null){
      setState(() {
        discussoes = (jsonDecode(cacheData) as List)
        .map((discussoesJson) => Discussao.fromJson(discussoesJson))
        .toList();
      });
    }
    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/forum_disciplines');
    try {
      final response = await http.post(url, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      }, body: {
        'discipline_id': widget.disciplineId.toString()
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          discussoes = data
              .map((discussoesJson) =>
                  Discussao.fromJson(discussoesJson as Map<String, dynamic>))
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
      print('Erro: ${e}');
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
          title: Text('Forum'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
              itemCount: discussoes.length,
              itemBuilder: (Context, index){
                final discussao = discussoes[index];
                return ListTile(
                  title: Text(discussao.titulo),
                  subtitle: Text('Autor: ${discussao.autor}, Data: ${discussao.data}'),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForumCommentsPage(forumId: discussao.id,)));
                  },
                );
              }));
  }
}
