// utils/documentos_web.dart
import 'dart:html' as html;
import 'download_interface.dart';
import 'package:flutter/material.dart';

class DownloadWeb implements DownloadInterface {
  @override
  Future<void> downloadPdf(String url, String fileName, BuildContext context) async {
    try {
      html.AnchorElement anchor = html.AnchorElement(href: url);
      anchor.download = fileName;
      anchor.click();
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Função para criar a implementação correta no ambiente web
DownloadInterface createDownloaderImpl() {
  return DownloadWeb();
}
