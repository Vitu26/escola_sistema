import 'dart:convert';
import 'package:app/model/material_disciplinas_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';

class MateriaisPage extends StatefulWidget {
  final int disciplineId;

  const MateriaisPage({required this.disciplineId, Key? key}) : super(key: key);

  @override
  _MateriaisPageState createState() => _MateriaisPageState();
}

class _MateriaisPageState extends State<MateriaisPage> {
  List<MaterialDisciplina> materiais = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchMateriais();
  }

  Future<void> fetchMateriais() async {
    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/materiais_disciplines');

    try {
      final bodyContent = {
        'discipline_id': widget.disciplineId.toString(),
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: bodyContent,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          materiais = data
              .map((materialJson) => MaterialDisciplina.fromJson(materialJson))
              .toList();
          isLoading = false;
        });
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

  // Future<void> downloadAndOpenFile(String url, String fileName) async {
  //   try {
  //     print('Download URL: $url');
  //     final dio = Dio();

  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/$fileName';
  //     print('Saving file to: $filePath');

  //     await dio.download(url, filePath);

  //     OpenFile.open(filePath);
  //   } catch (e) {
  //     print('Erro ao baixar o arquivo: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materiais da Disciplina'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar materiais.'))
              : ListView.builder(
                  itemCount: materiais.length,
                  itemBuilder: (context, index) {
                    final material = materiais[index];
                    return ListTile(
                      title: Text(material.titulo),
                      subtitle: Text('Clique para baixar'),
                      trailing: Icon(Icons.download),
                      onTap: () {
                        // downloadAndOpenFile(
                        //     material.link, material.titulo + '.pdf');
                      },
                    );
                  },
                ),
    );
  }
}
