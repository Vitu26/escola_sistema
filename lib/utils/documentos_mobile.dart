// utils/documentos_mobile.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'download_interface.dart';
import 'package:flutter/material.dart';

class DownloadMobile implements DownloadInterface {
  @override
  Future<void> downloadPdf(String url, String fileName, BuildContext context) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        var dir = await getExternalStorageDirectory();
        String savePath = '${dir!.path}/$fileName';

        await Dio().download(url, savePath);

        // Exibe um diálogo de sucesso
        _showDownloadSuccessDialog(context, savePath);
      } else {
        throw Exception('Permissão negada.');
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showDownloadSuccessDialog(BuildContext context, String savePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download Concluído'),
          content: Text('Arquivo salvo em $savePath'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

// Função para criar a implementação correta no ambiente móvel
DownloadInterface createDownloaderImpl() {
  return DownloadMobile();
}
