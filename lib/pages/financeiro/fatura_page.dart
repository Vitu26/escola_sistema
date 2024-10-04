import 'dart:typed_data';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class FaturaPage extends StatelessWidget {
  final Map<String, dynamic> fatura;

  const FaturaPage({
    Key? key,
    required this.fatura,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String svgBase64 = fatura['pix']['qrcode_image'].split(',').last;
    final Uint8List svgBytes = base64.decode(svgBase64);

    return Scaffold(
      appBar:
          CustomAppbar(title: 'Emitir Fatura', elevation: 8.0,),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código de Barras'),
              Text(fatura['barcode']),
              SizedBox(height: 10),
              Text('QR Code'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    child: SvgPicture.memory(svgBytes),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // Copia o código PIX para a área de transferência
                  Clipboard.setData(
                      ClipboardData(text: fatura['pix']['qrcode']));
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Código PIX copiado!')));
                },
                icon: Icon(Icons.copy),
                label: Text('Copiar PIX'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
