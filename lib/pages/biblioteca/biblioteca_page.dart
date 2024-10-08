import 'dart:convert';

import 'package:app/model/biblioteca_model.dart';
import 'package:app/utils/api_service.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/drawer.dart';
import 'package:flutter/material.dart';

class BibliotecaPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const BibliotecaPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  List<Biblioteca> bibliotecas = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Bibliotecas';
  final ApiService apiService = ApiService();
  final String cacheKey = 'bibliotecas_cache';

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    fetchBiblioteca();
  }

  Future<void> fetchBiblioteca() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url = 'https://app.tresmarias.edu.br/api/v1/bibliotecas';

    try {
      final response = await apiService.postWithAuth(url: url, useCache: true);
      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          bibliotecas = data
              .map((bibliotecasJson) =>
                  Biblioteca.fromJson(bibliotecasJson as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        print('Erro na requisição da api: ${response?.body}');
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar bibliotecas: ${e}');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF094366),
        appBar: CustomAppbar(
          title: selectedPage,
        ),
        drawer: CustomDrawer(
            onItemTap: onItemTap,
            nomeAluno: widget.nomeAluno,
            idMatricula: widget.idMatricula),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Bibliotecas',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        height: 3,
                        thickness: 2,
                        color: Colors.black,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bibliotecas.length,
                          itemBuilder: (context, index) {
                            final biblioteca = bibliotecas[index];
                            return ListTile(
                              title: Text(biblioteca.biblioteca),
                              onTap: () {
                                print(
                                    'Biblioteca selecionada: ${biblioteca.biblioteca}');
                              },
                            );
                          })
                    ]),
                  )
                ],
              ));
  }
}
