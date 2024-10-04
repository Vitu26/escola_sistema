// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app/model/notas_model.dart';
import 'package:app/widgets/drawer.dart';

class NotasPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const NotasPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  String selectedPage = 'Minhas notas';
  Map<String, dynamic> notasPorPeriodo = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchNotasData();
  }

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  Future<void> fetchNotasData() async {
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/notas');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          notasPorPeriodo =
              (data as Map<String, dynamic>).map((periodo, notas) {
            return MapEntry(
              periodo,
              (notas as List)
                  .map((notaJson) => Nota.fromJson(notaJson))
                  .toList(),
            );
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: CustomAppbar(title: selectedPage),
      drawer: CustomDrawer(
          onItemTap: onItemTap,
          nomeAluno: widget.nomeAluno,
          idMatricula: widget.idMatricula),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar notas.'))
              : Container(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: ListView(
                    children: notasPorPeriodo.entries.map((entry) {
                      final periodo = entry.key;
                      final notas = entry.value as List<Nota>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Período: $periodo',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ),
                          ...notas.map((nota) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0)),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nota.disciplina,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Nota: ${nota.nota ?? 'sem nota'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
              ),
    );
  }
}
