import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/drawer.dart';
import 'package:flutter/material.dart';

class HomePageAluno extends StatefulWidget {
  final String nomeAluno;
  final String? fotoAluno;
  final String idMatricula;

  const HomePageAluno({
    super.key,
    required this.nomeAluno,
    this.fotoAluno,
    required this.idMatricula,
  });

  @override
  State<HomePageAluno> createState() => _HomePageAlunoState();
}

class _HomePageAlunoState extends State<HomePageAluno> {
  String selectedPage = 'Home Aluno';
  bool _isFullScreen = false;
  List<String> banners = [];
  List<String> informativos = [];

  @override
  void initState() {
    super.initState();
    fetchBannersAndInformativos();
  }

  Future<void> fetchBannersAndInformativos() async {
    setState(() {
      banners = [
        'https://corsproxy.io/?https://via.placeholder.com/400x200',
        'https://corsproxy.io/?https://via.placeholder.com/400x200',
      ];
      informativos = [
        'Informativo 1: Detalhes importantes sobre a aula.',
        'Informativo 2: Novo conteúdo disponível.',
        'Informativo 3: Horários atualizados.',
      ];
    });
  }

  void onItemTap(String page) {
    setState(() {
      selectedPage = page;
    });
    Navigator.of(context).pop();
  }

  void _onFullScreenChanged(bool isFullScreen) {
    setState(() {
      _isFullScreen = isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF094366),
      appBar: _isFullScreen
          ? null
          : CustomAppbar(
              title: selectedPage,
            ),
      drawer: _isFullScreen
          ? null
          : CustomDrawer(
              onItemTap: onItemTap,
              nomeAluno: widget.nomeAluno,
              idMatricula: widget.idMatricula,
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ...banners.map((url) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calcula a largura da imagem com base na largura disponível.
                    double imageWidth = constraints.maxWidth;
                    // Define a altura proporcional, com um limite máximo.
                    double imageHeight = (imageWidth * 0.35)
                        .clamp(100.0, 200.0); // Altura mínima 100 e máxima 200.

                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: imageWidth,
                      height: imageHeight,
                      filterQuality: FilterQuality.high,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          height: imageHeight,
                          width: imageWidth,
                          child: Center(
                            child: Text(
                              'Erro ao carregar o banner',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )),
          ...informativos.map((info) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ComunicadosPage(),
              )),
        ],
      ),
    );
  }
}

class ComunicadosPage extends StatelessWidget {
  final List<String> comunicados = [
    'Prezados alunos, iniciaremos o semestre 2024.2 no dia 29 de julho. Dessa forma, a renovação de matrícula será feita através do sistema acadêmico, a partir do dia 08 de julho encerrando dia 31 de julho. O aluno que não renovar matrícula dentro do prazo estabelecido será cobrada uma taxa no valor de R\$ 50,00 e só após o pagamento ser compensado é que a renovação poderá ser realizada.\n\n'
        'Abaixo segue os requisitos para renovação:\n\n'
        'I. Não ter pendência de envio das documentações (RG, CPF, COMPROVANTE DE RESIDÊNCIA, TÍTULO ELEITORAL, HISTÓRICO E CERTIDÃO DE CONCLUSÃO DO ENSINO MÉDIO, CERTIDÃO DE NASCIMENTO OU CASAMENTO E RESERVISTA (HOMENS)).\n'
        'II. Não ter pendência financeira.\n\n'
        'Observação:\n'
        'O aluno que possuir alguma pendência deverá entrar em contato com o 0800 083 2656 e escolher a opção 1 – secretaria acadêmica ou 2 - Departamento financeiro para regularizar sua situação.\n\n'
        'Todos os procedimentos acima relacionados devem ser seguidos dentro do prazo.\n'
        'Atenciosamente,\n'
        'João Pessoa, 08 de julho de 2024.',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comunicados.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FACULDADE TRÊSMARIAS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  comunicados[index],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Segunda-Feira, 08 de Julho de 2024',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
