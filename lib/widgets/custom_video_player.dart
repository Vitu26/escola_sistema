import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class BetterVideoPlayerPage extends StatefulWidget {
  final String url;

  const BetterVideoPlayerPage({Key? key, required this.url}) : super(key: key);

  @override
  _BetterVideoPlayerPageState createState() => _BetterVideoPlayerPageState();
}

class _BetterVideoPlayerPageState extends State<BetterVideoPlayerPage> {
  late BetterPlayerController _betterPlayerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBetterPlayer();
  }

  Future<void> _initializeBetterPlayer() async {
    try {
      // Configuração do DataSource sem necessidade de token, apenas com headers básicos
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url,
        headers: {
          // Remova ou ajuste os headers conforme necessário
          'User-Agent': 'BetterPlayer',
        },
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: 5000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 3000,
        ),
      );

      // Inicialização do controlador do BetterPlayer
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableFullscreen: true,
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      // Adicione um listener para capturar eventos do player e debuggar se necessário
      _betterPlayerController.addEventsListener((event) {
        print('BetterPlayer Event: ${event.betterPlayerEventType}');
        if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          print('Erro no BetterPlayer: ${event.parameters}');
        }
      });

      setState(() {
        _isInitialized = true; // Indica que o controlador foi inicializado
      });
    } catch (e) {
      print('Erro ao inicializar o BetterPlayer: $e');
    }
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reprodutor Better Player'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reprodutor Better Player'),
      ),
      body: Center(
        child: BetterPlayer(controller: _betterPlayerController),
      ),
    );
  }
}
