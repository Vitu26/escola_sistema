// utils/download_factory.dart
import 'download_interface.dart';

// Importa a implementação correta com base na plataforma
import 'documentos_mobile.dart' if (dart.library.html) 'documentos_web.dart';

// A função retorna a implementação correta, resolvida automaticamente pela importação condicional
DownloadInterface createDownloader() {
  return createDownloaderImpl(); // Chama uma função implementada na importação condicional
}
