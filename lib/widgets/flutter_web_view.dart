import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VideoWebView extends StatelessWidget {
  final String url;

  VideoWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizador de Vídeo'),
      ),
      body: InAppWebView(
        // Corrigido: criação correta do WebUri
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onWebViewCreated: (controller) {
          print('WebView criada para URL: $url');
        },
        onLoadError: (controller, url, code, message) {
          print('Erro ao carregar o vídeo: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar o vídeo. Tente novamente.'),
            ),
          );
        },
      ),
    );
  }
}
