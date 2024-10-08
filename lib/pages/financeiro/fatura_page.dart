import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:app/widgets/custom_app_bar.dart';

class FaturaPage extends StatelessWidget {
  final Map<String, dynamic> fatura;

  const FaturaPage({
    Key? key,
    required this.fatura,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verifica se o código de barras e o QR Code estão presentes
    final String? barCode = fatura['barcode'];
    final String? pixQRCodeImage = fatura['pix']?['qrcode_image'];
    final String? pixQRCode = fatura['pix']?['qrcode'];

    // Decodifica a imagem do QR Code em SVG, se estiver presente
    Uint8List? svgBytes;
    if (pixQRCodeImage != null && pixQRCodeImage.isNotEmpty) {
      final String svgBase64 = pixQRCodeImage.split(',').last;
      svgBytes = base64.decode(svgBase64);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: CustomAppbar(
        title: 'Emitir Fatura',
        elevation: 8.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de Código de Barras
            if (barCode != null) ...[
              _buildSectionTitle('Código de Barras'),
              _buildBarCodeBox(barCode),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: barCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Código de Barras copiado para a área de transferência!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Código de Barras'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Seção de QR Code
            if (svgBytes != null) ...[
              _buildSectionTitle('QR Code para Pagamento'),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.memory(svgBytes, height: 200, width: 200),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Botão de copiar código PIX
            if (pixQRCode != null) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: pixQRCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Código PIX copiado para a área de transferência!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Código PIX'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            // Mensagem de erro, caso dados estejam ausentes
            if (barCode == null && pixQRCode == null) ...[
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Informações de pagamento indisponíveis.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Método para criar título de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Método para exibir o código de barras com estilo
  Widget _buildBarCodeBox(String barCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SelectableText(
        barCode,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
