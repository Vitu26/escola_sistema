import 'dart:convert';
import 'package:app/utils/cache_manager.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/api_service.dart';
import 'package:app/model/laboratorios_model.dart';
import 'package:app/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class LaboratoriosPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const LaboratoriosPage({
    super.key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: CustomAppbar(title: selectedPage),
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
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Erro ao carregar laboratórios.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            selectedPage,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 18),
                          ),
                          const SizedBox(height: 10,),
                          const Divider(
                            height: 1,
                            thickness: 2,
                            color: Colors.black,
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: laboratorio.length,
                              itemBuilder: (context, index) {
                                final laboratorios = laboratorio[index];
                                return ListTile(
                                  title: Text(laboratorios.laboratorio),
                                  onTap: () {},
                                );
                              })
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
