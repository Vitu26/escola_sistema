// documents_page.dart
import 'dart:convert';
import 'package:app/utils/cache_manager.dart';
import 'package:app/utils/download_interface.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Importa kIsWeb para detectar a plataforma
import 'package:flutter/material.dart';
import 'package:app/model/documentos_model.dart';
import 'package:app/widgets/drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:app/utils/download_factory.dart'; // Importa a fábrica de downloads

// Use a função createDownloader para instanciar a implementação correta
final DownloadInterface downloader = createDownloader();

class DocumentsPage extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const DocumentsPage({
    super.key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  });

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Documents> documents = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedPage = 'Home Aluno';
  final CacheManager cacheManager = CacheManager();
  final String cacheKey = 'documents_cache';

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final cacheData = await cacheManager.getFromCache(cacheKey);
    if (cacheData != null) {
      setState(() {
        documents = (jsonDecode(cacheData) as List)
            .map((documentsJson) => Documents.fromJson(documentsJson))
            .toList();
      });
    }

    final url = Uri.parse('https://app.tresmarias.edu.br/api/v1/documents');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['documents'] as List<dynamic>;
        setState(() {
          documents = data
              .map((docJson) =>
                  Documents.fromJson(docJson as Map<String, dynamic>))
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
      print('Erro ao buscar documentos: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void downloadPdf(String url, String fileName) {
    downloader.downloadPdf(url, fileName, context);
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
            idMatricula: widget.idMatricula),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(child: Text('Erro ao carregar documentos.'))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Documentos',
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
                            Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                  itemCount: documents.length,
                                  itemBuilder: (context, index) {
                                    final documentos = documents[index];
                                    return Container(
                                        child: ListTile(
                                      title: Text(documentos.title),
                                      subtitle: const Text(
                                          'Clique para visualizar'),
                                      trailing: !kIsWeb
                                          ? IconButton(
                                              icon: const Icon(
                                                  FontAwesomeIcons.filePdf),
                                              onPressed: () {
                                                downloadPdf(documentos.link,
                                                    documentos.title + '.pdf');
                                              },
                                            )
                                          : null, // Ícone aparece somente em plataformas móveis
                                      onTap: () {
                                        if (kIsWeb) {
                                          // Se estiver na web, chama o downloadPdf diretamente
                                          downloadPdf(documentos.link,
                                              documentos.title + '.pdf');
                                        } else {
                                          // Em plataformas móveis, navega para a visualização do PDF
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PdfViewerPage(
                                                pdfUrl: documentos.link,
                                                document: documentos,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ));
                                  }),
                            ),
                          ],
                        ),
                      )
                    ],
                  ));
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;
  final Documents document;
  const PdfViewerPage({Key? key, required this.pdfUrl, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de PDF'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                downloadPdf(document.link, document.title + '.pdf', context);
              },
              icon: const Icon(FontAwesomeIcons.filePdf))
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowPaginationDialog: true,
        canShowScrollStatus: true,
        enableDocumentLinkAnnotation: true,
        enableDoubleTapZooming: true,
      ),
    );
  }

  void downloadPdf(String url, String fileName, BuildContext context) {
    downloader.downloadPdf(url, fileName, context);
  }
}
