import 'dart:convert';
import 'package:app/model/comentarios_model.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForumCommentsPage extends StatefulWidget {
  final int forumId;

  const ForumCommentsPage({Key? key, required this.forumId}) : super(key: key);

  @override
  _ForumCommentsPageState createState() => _ForumCommentsPageState();
}

class _ForumCommentsPageState extends State<ForumCommentsPage> {
  List<Comentario> comentarios = [];
  bool isLoading = true;
  bool hasError = false;
  TextEditingController messageController = TextEditingController();
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'comentarios_cache';

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final cacheData = await cacheManager.getFromCache(cacheKey);
    if(cacheData != null) {
      comentarios = (jsonDecode(cacheData) as List)
      .map((comentarioJson) => Comentario.fromJson(comentarioJson))
      .toList();
    }

    
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/forum_comments');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'forum_id': widget.forumId.toString(),
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          comentarios = data
              .map((comentarioJson) => Comentario.fromJson(comentarioJson))
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
      print('Erro ao buscar comentários: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> responderForum({int? commentId}) async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/responder_forum');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'forum_id': widget.forumId.toString(),
          if (commentId != null) 'comment_id': commentId.toString(),
          'message': messageController.text,
        },
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          messageController.clear();
        });
        fetchComments(); // Atualiza os comentários após adicionar uma resposta
      } else {
        print('Erro ao responder: ${response.body}');
      }
    } catch (e) {
      print('Erro ao responder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentários do Fórum'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar comentários.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: comentarios.length,
                        itemBuilder: (context, index) {
                          final comentario = comentarios[index];
                          return ListTile(
                            title: Text(comentario.comment),
                            subtitle: Text(
                                'Autor: ${comentario.autor}\nData: ${comentario.data}'),
                            trailing: IconButton(
                              icon: Icon(Icons.reply),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Responder'),
                                    content: TextField(
                                      controller: messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Digite sua resposta...',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          responderForum(
                                              commentId: comentario.id);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Responder'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: 'Digite sua mensagem...',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              responderForum();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

