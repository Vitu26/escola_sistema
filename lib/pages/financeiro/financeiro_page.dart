import 'dart:convert';

import 'package:app/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/financial_model.dart';
import 'package:app/pages/financeiro/fatura_page.dart';
import 'package:app/utils/api_service.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/drawer.dart';

class FinanceiroPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;
  const FinanceiroPage({
    Key? key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  }) : super(key: key);

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  List<Parcela> parcelas = [];
  bool isLoading = true;
  String selectedPage = 'Financeiro';
  bool hasError = false;
  final CacheManager cacheManager = CacheManager();
  final ApiService apiService = ApiService();
  final String cacheKey = 'parcelas_cache';

  @override
  void initState() {
    super.initState();
    fetchFinanceiroData();
  }

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  // Future<void> fetchFinanceiroData() async {
  //   setState(() {
  //     isLoading = true;
  //     hasError = false;
  //   });

  //   final url = 'https://app.tresmarias.edu.br/api/v1/financial';

  //   try {
  //     // Chama o método do ApiService para fazer a requisição com autenticação
  //     final response = await apiService.postWithAuth(
  //       url: url,
  //       body: {}, // Adicione os parâmetros necessários aqui
  //       useCache: true, // Utilize o cache se aplicável
  //     );

  //     if (response != null && response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       if (data.containsKey('parcelas') && data['parcelas'] is List) {
  //         setState(() {
  //           parcelas = (data['parcelas'] as List)
  //               .map((parcelaJson) => Parcela.fromJson(parcelaJson))
  //               .toList();
  //           isLoading = false;
  //         });
  //       } else {
  //         print('Campo "parcelas" não encontrado ou formato incorreto');
  //         setState(() {
  //           hasError = true;
  //           isLoading = false;
  //         });
  //       }
  //     } else {
  //       print('Erro ao carregar dados financeiros: ${response?.statusCode}');
  //       setState(() {
  //         hasError = true;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Erro na requisição: $e');
  //     setState(() {
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchFinanceiroData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final cacheData = await cacheManager.getFromCache(cacheKey);
    if (cacheData != null) {
      parcelas = (jsonDecode(cacheData) as List)
          .map((parcelaJson) => Parcela.fromJson(parcelaJson))
          .toList();
    }
    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/financial');
    try {
      final response = await http.post(url);
      String responseBody = response.body;

      // Remover todos os caracteres não imprimíveis do início da string (incluindo o BOM)
      responseBody = responseBody.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

      print(responseBody);

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);

        if (data.containsKey('parcelas') && data['parcelas'] is List) {
          setState(() {
            parcelas = (data['parcelas'] as List)
                .map((parcelaJson) => Parcela.fromJson(parcelaJson))
                .toList();
            isLoading = false;
          });
        } else {
          print('Campo "parcelas" não encontrado ou formato incorreto');
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        print(
            'Erro ao carregar dados financeiros: Status code: ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro de exceção: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> emitirFatura(int transactionId) async {
    print('transactionId: $transactionId, tipo: ${transactionId.runtimeType}');

    final url =
        'https://app.tresmarias.edu.br/api/v1/emitir_fatura?transaction_id=$transactionId';

    try {
      // Utiliza o ApiService para fazer a requisição GET com autenticação
      final response = await apiService.makeRequest(
        url: url,
        method: 'GET',
        headers: {
          'Accept': 'application/json', // Apenas o cabeçalho Accept
        },
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final fatura = data['data'];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FaturaPage(fatura: fatura),
          ),
        );
      } else {
        print('Erro ao emitir fatura: ${response?.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width < 600; // Responsividade

    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: CustomAppbar(
        title: selectedPage,
        elevation: 16.0,
      ),
      drawer: CustomDrawer(
        onItemTap: onItemTap,
        nomeAluno: widget.nomeAluno,
        idMatricula: widget.idMatricula,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : hasError
              ? const Center(
                  child: Text('Erro ao carregar dados financeiros'),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.yellow[100],
                      child: Center(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text:
                                      'Temos condições especiais para você negociar a sua dívida '),
                              TextSpan(
                                text: 'Clique aqui',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Minhas faturas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Listagem adaptada para mobile
                          if (isMobile)
                            Column(
                              children: parcelas.map((parcela) {
                                // Determinar a cor com base no status
                                Color itemColor;
                                if (parcela.status == 'pago') {
                                  itemColor = Colors.green[100]!;
                                } else if (parcela.isVencida) {
                                  itemColor = Colors.red[100]!;
                                } else {
                                  itemColor =
                                      Colors.white; // Status em aberto ou outro
                                }

                                return Container(
                                  color: itemColor,
                                  padding: const EdgeInsets.all(
                                      16), // Padding interno
                                  child: Row(
                                    children: [
                                      // Coluna expandida com informações da fatura
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Referência: ${parcela.referencia}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                'Vencimento: ${parcela.dataVencimento}'),
                                          ],
                                        ),
                                      ),
                                      // Botão ou texto de status
                                      parcela.status == 'pago'
                                          ? Text(
                                              'Pago',
                                              style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: () {
                                                emitirFatura(
                                                    parcela.transactionId);
                                              },
                                              child: Text('Pagar'),
                                            ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Fatura #')),
                                  DataColumn(
                                      label: Text('Referência da fatura')),
                                  DataColumn(label: Text('Data de vencimento')),
                                  DataColumn(label: Text('Ação')),
                                ],
                                rows: parcelas.map((parcela) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('#')),
                                      DataCell(Text(parcela.referencia)),
                                      DataCell(Text(parcela.dataVencimento)),
                                      DataCell(
                                        parcela.status == 'pago'
                                            ? Text(
                                                'Pago',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              )
                                            : ElevatedButton(
                                                onPressed: () {
                                                  emitirFatura(
                                                      parcela.transactionId);
                                                },
                                                child: Text('Pagar'),
                                              ),
                                      ),
                                    ],
                                    color: MaterialStateProperty.resolveWith<
                                        Color?>(
                                      (Set<MaterialState> states) {
                                        if (parcela.status == 'pago') {
                                          return Colors.green[100];
                                        } else if (parcela.isVencida) {
                                          return Colors.red[100];
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[100],
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Informação importante',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Prezado aluno, em nenhuma hipótese, é permitido o pagamento em mãos. '
                            'Todo o pagamento deverá ser feito via boleto bancário, sob pena de não ser considerado.',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
