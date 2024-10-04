import 'dart:convert';
import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/api_service.dart'; // Certifique-se de importar o ApiService correto
import 'package:app/model/laboratorios_model.dart';
import 'package:app/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class LaboratoriosPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const LaboratoriosPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<LaboratoriosPage> createState() => _LaboratoriosPageState();
}

class _LaboratoriosPageState extends State<LaboratoriosPage> {
  List<Laboratorios> laboratorio = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Laboratório';
  final ApiService apiService = ApiService(); // Instanciando o ApiService
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'laboratorios_cache';

  @override
  void initState() {
    super.initState();
    fetchLaboratorios(); // Chama a função para buscar laboratórios
  }

  // Future<void> fetchLaboratorios() async {
  //   setState(() {
  //     isLoading = true;
  //     hasError = false;
  //   });
  //   final cacheData = await cacheManager.getFromCache(cacheKey);
  //   if (cacheData != null) {
  //     laboratorio = (jsonDecode(cacheData) as List)
  //         .map((laboratorioJson) => Laboratorios.fromJson(laboratorioJson))
  //         .toList();
  //   }
  //   final url =
  //       Uri.parse('https://app.tresmarias.edu.br/api/v1/laboratorios_virtuais');
  //   try {
  //     final response = await http.post(url, headers: {
  //       "Content-Type": "application/x-www-form-urlencoded",
  //     },);

  //     print('Resposta da API: ${response.body}');
  //     print('Status Code: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);

  //       setState(() {
  //         laboratorio = data
  //             .map((labJson) =>
  //                 Laboratorios.fromJson(labJson as Map<String, dynamic>))
  //             .toList();
  //         isLoading = false;
  //       });
  //     } else {
  //       print('Erro na resposta da API: ${response.body}');
  //       setState(() {
  //         hasError = true;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Erro ao buscar laboratórios: $e');
  //     setState(() {
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchLaboratorios() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url =
        Uri.parse('https://app.tresmarias.edu.br/api/v1/laboratorios_virtuais');

    // Obtém o token de autenticação
    String? token = await apiService.getToken();
    if (token == null) {
      print('Token ausente ou inválido.');
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    try {
      // Faz a requisição POST com o token de autenticação
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token", // Adiciona o token JWT no cabeçalho
        },
        body: {}, // Corpo vazio, como mostrado no Postman
      );

      print('Resposta da API: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          laboratorio = data
              .map((labJson) =>
                  Laboratorios.fromJson(labJson as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });

        // Salva no cache
        await cacheManager.saveToCache('laboratorios_cache', response.body);
      } else {
        print('Erro na resposta da API: ${response.body}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar laboratórios: $e');
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
        title: Text('Laboratórios Virtuais'),
      ),
      drawer: CustomDrawer(
        onItemTap: (page) {
          setState(() {
            selectedPage = page;
          });
          Navigator.of(context).pop();
        },
        nomeAluno: widget.nomeAluno,
        idMatricula: widget.idMatricula,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar laboratórios.'))
              : ListView.builder(
                  itemCount: laboratorio.length,
                  itemBuilder: (context, index) {
                    final laboratorios = laboratorio[index];
                    return ListTile(
                      title: Text(laboratorios.laboratorio),
                      onTap: () {
                        // Ação ao clicar em um laboratório
                        print(
                            'Laboratório selecionado: ${laboratorios.laboratorio}');
                      },
                    );
                  },
                ),
    );
  }
}
