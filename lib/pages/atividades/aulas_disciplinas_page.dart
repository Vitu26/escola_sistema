import 'dart:convert';
import 'package:app/model/aulas_disciplines_model.dart';
import 'package:app/utils/api_service.dart'; // Importe o ApiService
import 'package:app/widgets/custom_video_player.dart';
import 'package:flutter/material.dart';
import '../../widgets/flutter_web_view.dart';

class AulasDisciplinasPage extends StatefulWidget {
  final int disciplineId;

  const AulasDisciplinasPage({
    Key? key,
    required this.disciplineId,
  }) : super(key: key);

  @override
  State<AulasDisciplinasPage> createState() => _AulasDisciplinasPageState();
}

class _AulasDisciplinasPageState extends State<AulasDisciplinasPage> {
  List<Aulas> aulas = [];
  bool isLoading = true;
  bool hasError = false;
  final ApiService apiService = ApiService(); // Instancia o ApiService

  @override
  void initState() {
    super.initState();
    fetchAulas(); // Chama a função para buscar as aulas
  }

  Future<void> fetchAulas() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url = 'https://app.tresmarias.edu.br/api/v1/aulas_disciplines';

    try {
      // Codifica o corpo como uma string x-www-form-urlencoded
      final body = 'discipline_id=${Uri.encodeComponent(widget.disciplineId.toString())}';

      // Usa o ApiService para fazer a requisição com autenticação e cache
      final response = await apiService.makeRequest(
        url: url,
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body, // Envia o corpo codificado
        useCache: true, // Habilita o uso do cache
      );

      print('Resposta da API: ${response?.body}');
      print('Status Code: ${response?.statusCode}');

      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          aulas = data
              .map((aulaJson) =>
                  Aulas.fromJson(aulaJson as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        print('Erro: ${response?.body}');
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

  void _openVideo(String url) {
    print('Abrindo vídeo na URL: $url');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BetterVideoPlayerPage(url: url),
      ),
    ).catchError((error) {
      print('BetterPlayer falhou, abrindo WebView. Erro: $error');
      // Fallback to WebView if BetterPlayer fails
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoWebView(url: url),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aulas da Disciplina'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar aulas.'))
              : ListView.builder(
                  itemCount: aulas.length,
                  itemBuilder: (context, index) {
                    final aula = aulas[index];
                    return ListTile(
                      title: Text(aula.aula),
                      subtitle: Text('Clique para assistir'),
                      trailing: IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () => _openVideo(aula.link),
                      ),
                    );
                  },
                ),
    );
  }
}
