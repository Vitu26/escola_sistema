import 'dart:convert';

import 'package:app/model/secretaria_model.dart';
import 'package:app/utils/api_service.dart';
import 'package:app/utils/cache_manager.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SecretariaPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const SecretariaPage({
    super.key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  });

  @override
  State<SecretariaPage> createState() => _SecretariaPageState();
}

class _SecretariaPageState extends State<SecretariaPage> {
  List<Documento> documentos = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Secretaria';
  final CacheManager cacheManager = CacheManager();
  final ApiService apiService = ApiService();
  final String cacheKey = 'documentos_cache';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchDocumentos();
  }

  Future<void> fetchDocumentos() async {
  setState(() {
    isLoading = true;
    hasError = false;
  });

  final cacheData = await cacheManager.getFromCache(cacheKey);
  if (cacheData != null) {
    
    // Verifique se o cacheData é um Map e contém a chave 'documentos'
    final cachedJson = jsonDecode(cacheData);
    if (cachedJson is Map<String, dynamic> && cachedJson.containsKey('documentos')) {
      final documentosData = cachedJson['documentos'];
      
      if (documentosData is List) {
        setState(() {
          documentos = documentosData
              .map((docJson) => Documento.fromJson(docJson as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    }
  }

  final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/secretaria');
  try {

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      // Verifica se o campo 'documentos' está presente e é uma lista
      if (data is Map<String, dynamic> && data.containsKey('documentos')) {
        final documentosData = data['documentos'];

        if (documentosData is List) {
          setState(() {
            documentos = documentosData
                .map((docJson) => Documento.fromJson(docJson as Map<String, dynamic>))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }

        // Salvando no cache
        await cacheManager.saveToCache(cacheKey, response.body);
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
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



  // Future<void> fetchDocumentos() async {
  //   setState(() {
  //     isLoading = true;
  //     hasError = false;
  //   });

  //   final cacheData = await cacheManager.getFromCache(cacheKey);
  //   if (cacheData != null) {
  //     setState(() {
  //       documentos = (jsonDecode(cacheData) as List)
  //           .map((docJson) => Documento.fromJson(docJson))
  //           .toList();
  //     });
  //   }
  //   final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/secretaria');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/x-www-form-urlencoded",
  //       },
  //     );
  //     print('Resposta da API: ${response.body}');
  //     print('Status Code: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       setState(() {
  //         documentos = (data['documentos'] as List)
  //             .map((docJson) => Documento.fromJson(docJson))
  //             .toList();
  //         isLoading = false;
  //       });
  //       await cacheManager.saveToCache(
  //           cacheKey, response.body); // Salvando no cache
  //     } else {
  //       print('Erro na resposta da API: ${response.body}');
  //       setState(() {
  //         hasError = true;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Erro ao buscar documentos: $e');
  //     setState(() {
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  void abrirDocumento(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: CustomAppbar(title: selectedPage),
      drawer: CustomDrawer(onItemTap: onItemTap, nomeAluno: widget.nomeAluno, idMatricula: widget.idMatricula),
      body: isLoading ?
          const Center(child: CircularProgressIndicator.adaptive(backgroundColor: Colors.grey,),) :
      hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Erro ao carregar documentos.'),
                  ElevatedButton(
                    onPressed: fetchDocumentos,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : documentos.isEmpty
              ? const Center(
                  child: Text('Nenhum documento disponível'),
                )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    color: Colors.white,
                    child: const Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Secretária',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(
                          height: 5,
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documentos.length,
                      itemBuilder: (context, index) {
                        final documento = documentos[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: ListTile(
                            title: Text(documento.nome),
                            trailing: IconButton(
                              onPressed: () {
                                abrirDocumento(documento.link);
                              },
                              icon: const Icon(Icons.download),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
